import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';

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
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _dataLoaded = false;
  Map<String, Map<String, dynamic>> _machineData = {};
  final String _dataUrl = 'https://hrollur.com/data/scrape.html';
  String _fetchTime = '';
  String _dataInfo = '';

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _fetchTime = '';
      _dataInfo = '';
    });

    final startTime = DateTime.now();
    final scrapedData = await scrapeTableData(_dataUrl);
    final endTime = DateTime.now();

    if (scrapedData['error'] == false) {
      final rawData = scrapedData['data'] as List<Map<String, dynamic>>;
      _machineData = processMachineData(rawData);
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
          _dataLoaded = true;
          _fetchTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime);
          _dataInfo =
              'Data fetched successfully in ${endTime.difference(startTime).inMilliseconds}ms';
        });
      }
    } else {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
          _fetchTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime);
          _dataInfo = 'Failed to fetch data: ${scrapedData['errorMessage']}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch data: ${scrapedData['errorMessage']}')),
        );
      }
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _dataLoaded ? Colors.green : Colors.yellow,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.black)
                  : Text('Fetch Data'),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: _fetchTime.isNotEmpty
                  ? Text(
                      'Fetch Time: $_fetchTime',
                      style: TextStyle(color: Colors.grey),
                    )
                  : SizedBox.shrink(),
            ),
            SizedBox(
              height: 20,
              child: _dataInfo.isNotEmpty
                  ? Text(_dataInfo, style: TextStyle(color: Colors.grey))
                  : SizedBox.shrink(),
            ),
            SizedBox(height: 60),
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue), // Blue tint
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red), // Red tint
                  child: Text('South'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _dataLoaded
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HallScreen(
                                  hallName: 'Show All',
                                  machineData: _machineData)))
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green), // Green tint
                  child: Text('Show All'),
                ),
              ],
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
                                  hallName: 'Station 1 North',
                                  machineData: _machineData)))
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue), // Blue tint
                  child: Text('Station 1 North'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _dataLoaded
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HallScreen(
                                  hallName: 'Station 2 North',
                                  machineData: _machineData)))
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue), // Blue tint
                  child: Text('Station 2 North'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _dataLoaded
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HallScreen(
                                  hallName: 'Station 3 North',
                                  machineData: _machineData)))
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue), // Blue tint
                  child: Text('Station 3 North'),
                ),
              ],
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
                                  hallName: 'Station 1 South',
                                  machineData: _machineData)))
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red), // Red tint
                  child: Text('Station 1 South'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _dataLoaded
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HallScreen(
                                  hallName: 'Station 2 South',
                                  machineData: _machineData)))
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red), // Red tint
                  child: Text('Station 2 South'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _dataLoaded
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HallScreen(
                                  hallName: 'Station 3 South',
                                  machineData: _machineData)))
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red), // Red tint
                  child: Text('Station 3 South'),
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

  const HallScreen(
      {super.key, required this.hallName, required this.machineData});

  List<String> _generateMachineNumbers(String hallName) {
    List<String> machines = [];
    switch (hallName) {
      case 'North':
        for (int i = 901; i <= 932; i++) {
          machines.add('M$i');
        }
        break;
      case 'South':
        for (int i = 933; i <= 963; i++) {
          machines.add('M$i');
        }
        break;
      case 'Show All':
        for (int i = 901; i <= 963; i++) {
          machines.add('M$i');
        }
        break;
      case 'Station 1 North':
        for (int i = 901; i <= 911; i++) {
          machines.add('M$i');
        }
        break;
      case 'Station 2 North':
        for (int i = 917; i <= 927; i++) {
          machines.add('M$i');
        }
        break;
      case 'Station 3 North':
        for (int i = 912; i <= 916; i++) {
          machines.add('M$i');
        }
        for (int i = 928; i <= 932; i++) {
          machines.add('M$i');
        }
        break;
      case 'Station 1 South':
        for (int i = 938; i <= 947; i++) {
          machines.add('M$i');
        }
        break;
      case 'Station 2 South':
        for (int i = 953; i <= 963; i++) {
          machines.add('M$i');
        }
        break;
      case 'Station 3 South':
        for (int i = 933; i <= 937; i++) {
          machines.add('M$i');
        }
        for (int i = 948; i <= 952; i++) {
          machines.add('M$i');
        }
        break;
    }
    return machines;
  }

  @override
  Widget build(BuildContext context) {
    final machineNumbers = _generateMachineNumbers(hallName);
    return Scaffold(
      appBar: AppBar(title: Text(hallName)),
      body: Column(
        children: [
          Flexible(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: hallName == 'North' ? 8 : 8,
                childAspectRatio: 12 / 9,
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

                if (noRollsPlanned || currentRoll == null) {
                  machineColor = Colors.grey;
                } else {
                  machineColor = Colors.green;
                }

                return Stack(
                  children: [
                    GestureDetector(
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
                    ),
                    if (currentRoll != null && plannedRoll == null)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.warning_amber_outlined,
                            color: Colors.black,
                            size: 16.0,
                          ),
                        ),
                      ),
                    if (currentRoll != null &&
                        plannedRoll != null &&
                        !areRollsSame(currentRoll, plannedRoll))
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 16.0,
                          ),
                        ),
                      ),
                    if (currentRoll == null && plannedRoll != null)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.stop_circle_outlined,
                            color: Colors.white,
                            size: 16.0,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.black,
                    size: 16.0,
                  ),
                ),
                SizedBox(width: 8.0),
                Text('No plan after current roll'),
                SizedBox(width: 16.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),
                SizedBox(width: 8.0),
                Text('Working change after current roll'),
                SizedBox(width: 16.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),
                SizedBox(width: 8.0),
                Text('Not producing, but has planned rolls'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MachineDetailsPage extends StatelessWidget {
  final String machineNumber;
  final ProductionRoll? currentRoll;
  final ProductionRoll? plannedRoll;
  final bool noRollsPlanned;

  const MachineDetailsPage({
    super.key,
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
  const MyApp({super.key});

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
