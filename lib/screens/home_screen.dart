import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../screens/hall_screen.dart';

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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
