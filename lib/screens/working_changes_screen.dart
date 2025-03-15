import 'package:flutter/material.dart';
import '../models/production_roll.dart';

class WorkingChangesScreen extends StatelessWidget {
  const WorkingChangesScreen({super.key});

  String extractVolts(String finalProd) {
    try {
      RegExp regex = RegExp(r'(\d+)[Vv]F', caseSensitive: false);
      Match? match = regex.firstMatch(finalProd);
      if (match != null) {
        return match.group(1)!;
      } else {
        return 'N/A';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  int? tryParseInt(String? value) {
    if (value == null || value == 'N/A') {
      return null;
    }
    return int.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> machineData =
        ModalRoute.of(context)!.settings.arguments
            as Map<String, Map<String, dynamic>>;

    List<Map<String, dynamic>> northChanges = [];
    List<Map<String, dynamic>> southChanges = [];

    machineData.entries
        .where((entry) => entry.key.startsWith('M'))
        .forEach((machineEntry) {
      final machineId = machineEntry.key;
      int machineNumber;
      try {
        machineNumber = int.parse(machineId.substring(1));
      } catch (e) {
        return; // Skip if machine number parsing fails
      }

      List<Map<String, dynamic>> rolls = [];
      if (machineEntry.value['current'] != null) {
        rolls.add((machineEntry.value['current'] as ProductionRoll).toMap());
      }
      if (machineEntry.value['planned'] != null &&
          machineEntry.value['planned'] is List) {
        for (var roll in (machineEntry.value['planned'] as List)) {
          if (roll is ProductionRoll) {
            rolls.add(roll.toMap());
          }
        }
      }

      final wRoll = rolls.firstWhere(
        (roll) => roll['Status'] == 'W',
        orElse: () => <String, dynamic>{},
      );
      final qRolls = rolls.where((roll) => roll['Status'] == 'Q').toList();

      if (wRoll.isNotEmpty && qRolls.isNotEmpty) {
        final qRoll = qRolls.first;
        final wFinalProd = wRoll['FinalProd.'].toString().toLowerCase();
        final qFinalProd = qRoll['FinalProd.'].toString().toLowerCase();

        if (wFinalProd != qFinalProd) {
          final wVolts = extractVolts(wRoll['FinalProd.'].toString());
          final qVolts = extractVolts(qRoll['FinalProd.'].toString());
          final wVoltsInt = tryParseInt(wVolts);
          final qVoltsInt = tryParseInt(qVolts);
          final wSpeedInt = tryParseInt(wRoll['SpeedC']?.toString());
          final qSpeedInt = tryParseInt(qRoll['SpeedC']?.toString());
          final voltsDiff = wVoltsInt != null && qVoltsInt != null
              ? wVoltsInt - qVoltsInt
              : null;
          final speedDiff = wSpeedInt != null && qSpeedInt != null
              ? wSpeedInt - qSpeedInt
              : null;

          final changeData = {
            'Machine': machineId,
            'WRoll': wRoll,
            'QRoll': qRoll,
            'VoltsDiff': voltsDiff,
            'SpeedDiff': speedDiff,
          };

          if (machineNumber >= 901 && machineNumber <= 932) {
            northChanges.add(changeData);
          } else if (machineNumber >= 933 && machineNumber <= 963) {
            southChanges.add(changeData);
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Working Changes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: ColoredBox(
              color: const Color.fromARGB(50, 33, 149, 243),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text('North Side',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: northChanges.length,
                      itemBuilder: (context, index) {
                        final change = northChanges[index];
                        final wRoll = change['WRoll'];
                        final qRoll = change['QRoll'];
                        final voltsDiff = change['VoltsDiff'] as int?;
                        final speedDiff = change['SpeedDiff'] as int?;

                        Color circleColor = (voltsDiff != null &&
                                    (voltsDiff > 10 || voltsDiff < -10)) ||
                                (speedDiff != null &&
                                    (speedDiff > 5 || speedDiff < -5))
                            ? const Color.fromARGB(140, 246, 6, 6)
                            : const Color.fromARGB(140, 255, 235, 50);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(30, 5, 15, 5),
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Material(
                                    elevation: 3,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: circleColor,
                                      child: Text(
                                        change['Machine'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              const TextSpan(
                                                  text: 'Work in progress: '),
                                              TextSpan(
                                                  text:
                                                      '${wRoll['FinalProd.']} @ ${wRoll['SpeedC']} cm/min',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              const TextSpan(
                                                  text: 'Next roll in: '),
                                              TextSpan(
                                                  text:
                                                      '${qRoll['FinalProd.']}, @ ${qRoll['SpeedC']} cm/min',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        if (voltsDiff != null &&
                                                voltsDiff != 0 ||
                                            speedDiff != null && speedDiff != 0)
                                          RichText(
                                            text: TextSpan(
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style,
                                              children: <TextSpan>[
                                                if (voltsDiff != null &&
                                                    voltsDiff != 0)
                                                  const TextSpan(
                                                      text: 'Volt Change: '),
                                                if (voltsDiff != null &&
                                                    voltsDiff != 0)
                                                  TextSpan(
                                                      text:
                                                          '${voltsDiff > 0 ? '+' : ''}$voltsDiff V',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                if (voltsDiff != null &&
                                                    voltsDiff != 0 &&
                                                    speedDiff != null &&
                                                    speedDiff != 0)
                                                  const TextSpan(text: ', '),
                                                if (speedDiff != null &&
                                                    speedDiff != 0)
                                                  const TextSpan(
                                                      text: 'Speed Change: '),
                                                if (speedDiff != null &&
                                                    speedDiff != 0)
                                                  TextSpan(
                                                      text:
                                                          '${speedDiff > 0 ? '+' : ''}$speedDiff cm/min',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color.fromARGB(48, 249, 118, 3),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text('South Side',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: southChanges.length,
                      itemBuilder: (context, index) {
                        final change = southChanges[index];
                        final wRoll = change['WRoll'];
                        final qRoll = change['QRoll'];
                        final voltsDiff = change['VoltsDiff'] as int?;
                        final speedDiff = change['SpeedDiff'] as int?;

                        Color circleColor = (voltsDiff != null &&
                                    (voltsDiff > 10 || voltsDiff < -10)) ||
                                (speedDiff != null &&
                                    (speedDiff > 5 || speedDiff < -5))
                            ? const Color.fromARGB(140, 246, 6, 6)
                            : const Color.fromARGB(140, 255, 235, 50);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 30, 5),
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Material(
                                    elevation: 3,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: circleColor,
                                      child: Text(
                                        change['Machine'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              const TextSpan(
                                                  text: 'Work in progress: '),
                                              TextSpan(
                                                  text:
                                                      '${wRoll['FinalProd.']}, @ ${wRoll['SpeedC']} cm/min',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              const TextSpan(
                                                  text: 'Next roll in: '),
                                              TextSpan(
                                                  text:
                                                      '${qRoll['FinalProd.']}, @ ${qRoll['SpeedC']} cm/min',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        if (voltsDiff != null &&
                                                voltsDiff != 0 ||
                                            speedDiff != null && speedDiff != 0)
                                          RichText(
                                            text: TextSpan(
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style,
                                              children: <TextSpan>[
                                                if (voltsDiff != null &&
                                                    voltsDiff != 0)
                                                  const TextSpan(
                                                      text: 'Volt Change: '),
                                                if (voltsDiff != null &&
                                                    voltsDiff != 0)
                                                  TextSpan(
                                                      text:
                                                          '${voltsDiff > 0 ? '+' : ''}$voltsDiff V',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                if (voltsDiff != null &&
                                                    voltsDiff != 0 &&
                                                    speedDiff != null &&
                                                    speedDiff != 0)
                                                  const TextSpan(text: ', '),
                                                if (speedDiff != null &&
                                                    speedDiff != 0)
                                                  const TextSpan(
                                                      text: 'Speed Change: '),
                                                if (speedDiff != null &&
                                                    speedDiff != 0)
                                                  TextSpan(
                                                      text:
                                                          '${speedDiff > 0 ? '+' : ''}$speedDiff cm/min',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
