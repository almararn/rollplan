import 'package:dio/dio.dart';
import 'package:html/parser.dart' as parser;
import '../models/production_roll.dart';

Future<Map<String, dynamic>> scrapeTableData(String url) async {
  try {
    final dio = Dio();
    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'Cache-Control': 'max-age=0',
    };

    final response = await dio.get(url, options: Options(headers: headers));

    if (response.statusCode == 200) {
      final document = parser.parse(response.data);
      final tables = document.querySelectorAll('table.table');
      if (tables.isNotEmpty) {
        final table = tables.first;

        List<Map<String, dynamic>> allMachineData = [];
        String currentMachine = '';

        final rows = table.querySelectorAll('tr');
        List<String> headersList = [];

        for (int i = 0; i < rows.length; i++) {
          final row = rows[i];

          final machineHeading = row.querySelector('th[colspan="20"]');
          if (machineHeading != null) {
            currentMachine = machineHeading.text.trim();
            continue;
          }

          if (i == 0) {
            headersList =
                row.querySelectorAll('th').map((th) => th.text.trim()).toList();
            continue;
          }

          final cells = row.querySelectorAll('td');
          if (cells.isEmpty) continue;

          Map<String, dynamic> rowData = {};
          rowData['Machine'] = currentMachine;
          for (int j = 0; j < headersList.length; j++) {
            final header = headersList[j];
            final cellValue = cells.length > j ? cells[j].text.trim() : "";
            rowData[header] = cellValue;
          }

          final emRow =
              rows.length > i + 1 ? rows[i + 1].querySelectorAll('td') : [];
          if (emRow.isNotEmpty &&
              emRow[0].attributes['style']?.contains('border-top:0') == true) {
            rowData['Notes'] = emRow[1].text.trim();
            i++;
          } else {
            rowData['Notes'] = '';
          }

          allMachineData.add(rowData);
        }
        return {
          'data': allMachineData,
          'rawHtml': response.data,
          'error': false,
          'errorMessage': null
        };
      } else {
        return {
          'data': [],
          'rawHtml': response.data,
          'error': true,
          'errorMessage': "No tables found"
        };
      }
    } else {
      return {
        'data': [],
        'rawHtml': 'Request failed with status: ${response.statusCode}',
        'error': true,
        'errorMessage': 'Request failed with status: ${response.statusCode}'
      };
    }
  } catch (e) {
    return {
      'data': [],
      'rawHtml': 'Error: $e',
      'error': true,
      'errorMessage': 'Error: $e'
    };
  }
}

Map<String, Map<String, dynamic>> processMachineData(
    List<Map<String, dynamic>> rawData) {
  Map<String, Map<String, dynamic>> machineData = {};

  for (var item in rawData) {
    ProductionRoll roll = ProductionRoll.fromJson(item);
    if (!machineData.containsKey(roll.machine)) {
      machineData[roll.machine] = {
        'current': null,
        'planned': <ProductionRoll>[], // Initialize as a list
        'noRollsPlanned': false,
      };
    }

    if (roll.status == 'W') {
      machineData[roll.machine]!['current'] = roll;
    } else if (roll.status == 'Q') {
      machineData[roll.machine]!['planned'].add(roll); // Add to the list
    }
  }

  for (var item in rawData) {
    if (item['Roll Number'] == "No rolls planned") {
      if (machineData.containsKey(item['Machine'])) {
        machineData[item['Machine']]!['noRollsPlanned'] = true;
      }
    }
  }

  return machineData;
}

bool areRollsSame(ProductionRoll? current, ProductionRoll? planned) {
  if (current == null || planned == null) return false;
  return current.finalProd == planned.finalProd;
}
