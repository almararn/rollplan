import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class ProductionRoll {
  final String machine;
  final String rollNumber;
  final String status;
  final String sqm;
  final String width;
  final String etchedProd;
  final String finalProd;
  final String startTime;
  final String endTime;
  final String customer;
  final String order;
  final String location;
  final String azeta;
  final String speed;
  final String speedC;
  final String baseVolts;
  final String volts;
  final String notes;

  ProductionRoll({
    required this.machine,
    required this.rollNumber,
    required this.status,
    required this.sqm,
    required this.width,
    required this.etchedProd,
    required this.finalProd,
    required this.startTime,
    required this.endTime,
    required this.customer,
    required this.order,
    required this.location,
    required this.azeta,
    required this.speed,
    required this.speedC,
    required this.baseVolts,
    required this.volts,
    required this.notes,
  });

  factory ProductionRoll.fromJson(Map<String, dynamic> json) {
    return ProductionRoll(
      machine: json['Machine'] ?? '',
      rollNumber: json['Roll Number'] ?? '',
      status: json['Status'] ?? '',
      sqm: json['Sqm'] ?? '',
      width: json['Width'] ?? '',
      etchedProd: json['EtchedProd.'] ?? '',
      finalProd: json['FinalProd.'] ?? '',
      startTime: json['StartTime'] ?? '',
      endTime: json['EndTime'] ?? '',
      customer: json['Customer'] ?? '',
      order: json['Order'] ?? '',
      location: json['Location'] ?? '',
      azeta: json['Azeta'] ?? '',
      speed: json['Speed'] ?? '',
      speedC: json['SpeedC'] ?? '',
      baseVolts: json['Base/Volts'] ?? '',
      volts: json['Volts'] ?? '',
      notes: json['Notes'] ?? '',
    );
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
        'planned': null,
        'noRollsPlanned': false,
      };
    }

    if (roll.status == 'W') {
      machineData[roll.machine]!['current'] = roll;
    } else if (roll.status == 'Q' &&
        machineData[roll.machine]!['planned'] == null) {
      machineData[roll.machine]!['planned'] = roll;
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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _dataLoaded = false;
  Map<String, Map<String, dynamic>> _machineData = {}; // Corrected type
  final String _dataUrl = 'https://hrollur.com/data/scrape.html';

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final scrapedData = await scrapeTableData(_dataUrl);

    if (scrapedData['error'] == false) {
      final rawData = scrapedData['data'] as List<Map<String, dynamic>>;
      _machineData = processMachineData(rawData);
      setState(() {
        _isLoading = false;
        _dataLoaded = true;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to fetch data: ${scrapedData['errorMessage']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Factory Schedule')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchData,
              child:
                  _isLoading ? CircularProgressIndicator() : Text('Fetch Data'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _dataLoaded
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HallScreen(
                                  hallName: 'North',
                                  machineData: _machineData)))
                      : null,
                  child: Text('North'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _dataLoaded
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HallScreen(
                                  hallName: 'South',
                                  machineData: _machineData)))
                      : null,
                  child: Text('South'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HallScreen extends StatelessWidget {
  final String hallName;
  final Map<String, Map<String, dynamic>> machineData;

  HallScreen({required this.hallName, required this.machineData});

  List<String> _generateMachineNumbers(String hallName) {
    List<String> machines = [];
    if (hallName == 'North') {
      for (int i = 901; i <= 932; i++) {
        machines.add('M$i');
      }
    } else {
      for (int i = 933; i <= 962; i++) {
        machines.add('M$i');
      }
    }
    return machines;
  }

  @override
  Widget build(BuildContext context) {
    final machineNumbers = _generateMachineNumbers(hallName);
    return Scaffold(
      appBar: AppBar(title: Text(hallName)),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: hallName == 'North' ? 8 : 8,
          childAspectRatio: 16 / 9,
        ),
        itemCount: machineNumbers.length,
        itemBuilder: (context, index) {
          final machineNumber = machineNumbers[index];
          final machineInfo = machineData[machineNumber];
          final currentRoll = machineInfo?['current'] as ProductionRoll?;
          final plannedRoll = machineInfo?['planned'] as ProductionRoll?;
          final noRollsPlanned =
              machineInfo?['noRollsPlanned'] as bool? ?? false;
          Color machineColor;

          if (noRollsPlanned || (currentRoll == null && plannedRoll == null)) {
            machineColor = Colors.grey; // Gray for no rolls planned or off
          } else if (currentRoll != null && plannedRoll == null) {
            machineColor = Colors.yellow; // Yellow for working, no planned
          } else {
            machineColor = areRollsSame(currentRoll, plannedRoll)
                ? Colors.green
                : Colors.red; // Green/Red for working with planned
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineDetailsPage(
                    machineNumber: machineNumber,
                    currentRoll: currentRoll,
                    plannedRoll: plannedRoll,
                    noRollsPlanned: noRollsPlanned,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(4.0),
              color: machineColor,
              child: Center(
                child: Text(
                  machineNumber,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MachineDetailsPage extends StatelessWidget {
  final String machineNumber;
  final ProductionRoll? currentRoll;
  final ProductionRoll? plannedRoll;
  final bool noRollsPlanned;

  MachineDetailsPage({
    required this.machineNumber,
    required this.currentRoll,
    required this.plannedRoll,
    required this.noRollsPlanned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(machineNumber)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (noRollsPlanned)
                Text('No rolls planned for this machine.')
              else ...[
                Text('Current Roll:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (currentRoll != null) ...[
                  Text('Roll Number: ${currentRoll!.rollNumber}'),
                  Text('Status: ${currentRoll!.status}'),
                  Text('Final Product: ${currentRoll!.finalProd}'),
                  // Add other details here
                ] else
                  Text('No current roll data.'),
                SizedBox(height: 20),
                Text('Planned Roll:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (plannedRoll != null) ...[
                  Text('Roll Number: ${plannedRoll!.rollNumber}'),
                  Text('Status: ${plannedRoll!.status}'),
                  Text('Final Product: ${plannedRoll!.finalProd}'),
                  // Add other details here
                ] else
                  Text('No planned roll data.'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> scrapeTableData(String url) async {
  try {
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

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
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
          'rawHtml': response.body,
          'error': false,
          'errorMessage': null
        };
      } else {
        return {
          'data': [],
          'rawHtml': response.body,
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Factory Schedule App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
