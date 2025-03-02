// lib/widgets/machine_details_page.dart
import 'package:flutter/material.dart';
import '../models/production_roll.dart';
import '../services/data_service.dart';

class MachineDetailsPage extends StatelessWidget {
  final String machineNumber;
  final ProductionRoll? currentRoll;
  final List<ProductionRoll> plannedRolls;
  final bool noRollsPlanned;

  const MachineDetailsPage({
    super.key,
    required this.machineNumber,
    required this.currentRoll,
    required this.plannedRolls,
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
                const Text('No rolls planned for this machine.')
              else ...[
                const Text('Current Roll:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (currentRoll != null)
                  _buildRollCard(context, currentRoll!, null)
                else
                  const Text('No current roll data.'),
                const SizedBox(height: 20),
                if (plannedRolls.isNotEmpty) ...[
                  const Text('Planned Rolls:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _buildPlannedRollCards(
                        context, plannedRolls, currentRoll),
                  )
                ] else
                  const Text('No planned roll data.'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRollCard(
      BuildContext context, ProductionRoll roll, ProductionRoll? previousRoll) {
    Color leftBorderColor = Colors.grey;
    String finalProdChange = '';
    String speedCChange = '';

    if (previousRoll != null) {
      leftBorderColor =
          areRollsSame(previousRoll, roll) ? Colors.green : Colors.red;

      try {
        double currentVF = double.parse(
            roll.finalProd.split('/').last.replaceAll(RegExp(r'[^0-9.]'), ''));
        double previousVF = double.parse(previousRoll.finalProd
            .split('/')
            .last
            .replaceAll(RegExp(r'[^0-9.]'), ''));
        double vfDiff = currentVF - previousVF;
        if (vfDiff != 0) {
          finalProdChange =
              '(${vfDiff > 0 ? '+' : ''}${vfDiff.toStringAsFixed(1)} V)';
        }

        int currentSpeedC = int.parse(roll.speedC);
        int previousSpeedC = int.parse(previousRoll.speedC);
        int speedDiff = currentSpeedC - previousSpeedC;
        if (speedDiff != 0) {
          speedCChange = '(${speedDiff > 0 ? '+' : ''}$speedDiff cm/min)';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error parsing VF or SpeedC'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: leftBorderColor, width: 8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Roll Number: ${roll.rollNumber}'),
                Text('Status: ${roll.status}'),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Final Product: ${roll.finalProd} ',
                      ),
                      if (finalProdChange.isNotEmpty) // Add condition here
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  // Add BoxDecoration to round corners
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.circular(4), // Round corners
                                ),
                                child: Text(
                                  finalProdChange,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Speed: ${roll.speedC} cm/min ',
                      ),
                      if (speedCChange.isNotEmpty) // Add condition here
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  // Add BoxDecoration to round corners
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.circular(4), // Round corners
                                ),
                                child: Text(
                                  speedCChange,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPlannedRollCards(BuildContext context,
      List<ProductionRoll> rolls, ProductionRoll? currentRoll) {
    List<Widget> cards = [];

    for (int i = 0; i < rolls.length; i++) {
      ProductionRoll? previousRoll;
      if (i == 0 && currentRoll != null) {
        previousRoll = currentRoll;
      } else if (i > 0) {
        previousRoll = rolls[i - 1];
      }
      cards.add(_buildRollCard(context, rolls[i], previousRoll));
    }
    return cards;
  }
}
