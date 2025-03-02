import 'package:flutter/material.dart';
import '../models/production_roll.dart';
import '../widgets/machine_details_page.dart';
import '../services/data_service.dart';

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
          Expanded(
            // Use Expanded instead of Flexible
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
                final List<ProductionRoll> plannedRolls =
                    (machineInfo?['planned'] is List)
                        ? (machineInfo?['planned'] as List)
                            .cast<ProductionRoll>()
                        : <ProductionRoll>[];
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
                              plannedRolls: plannedRolls,
                              noRollsPlanned: noRollsPlanned,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        color: machineColor,
                        child: Center(
                          child: Text(
                            machineNumber,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    if (currentRoll != null && plannedRolls.isEmpty)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
                            Icons.warning_amber_outlined,
                            color: Colors.black,
                            size: 16.0,
                          ),
                        ),
                      ),
                    if (currentRoll != null &&
                        plannedRolls.isNotEmpty &&
                        !areRollsSame(currentRoll, plannedRolls.first))
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 16.0,
                          ),
                        ),
                      ),
                    if (currentRoll == null && plannedRolls.isNotEmpty)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.black,
                    size: 16.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Text('No plan after current roll'),
                const SizedBox(width: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Text('Working change after current roll'),
                const SizedBox(width: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Text('Not producing, but has planned rolls'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
