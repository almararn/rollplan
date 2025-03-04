import 'package:flutter/material.dart';
import '../models/production_roll.dart';
import '../services/data_service.dart';

class RollCard extends StatelessWidget {
  final ProductionRoll roll;
  final ProductionRoll? previousRoll;

  const RollCard({super.key, required this.roll, this.previousRoll});

  @override
  Widget build(BuildContext context) {
    Color leftBorderColor = Colors.grey;
    String finalProdChange = '';
    String speedCChange = '';

    if (previousRoll != null) {
      leftBorderColor =
          areRollsSame(previousRoll, roll) ? Colors.green : Colors.red;

      try {
        double currentVF = double.parse(
            roll.finalProd.split('/').last.replaceAll(RegExp(r'[^0-9.]'), ''));
        double previousVF =
            double.parse(previousRoll!.finalProd // Added null check (!)
                .split('/')
                .last
                .replaceAll(RegExp(r'[^0-9.]'), ''));
        double vfDiff = currentVF - previousVF;
        if (vfDiff != 0) {
          finalProdChange =
              '(${vfDiff > 0 ? '+' : ''}${vfDiff.toStringAsFixed(1)} V)';
        }

        int currentSpeedC = int.parse(roll.speedC);
        int previousSpeedC =
            int.parse(previousRoll!.speedC); // Added null check (!)
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
                      if (finalProdChange.isNotEmpty)
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
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
                      if (speedCChange.isNotEmpty)
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  speedCChange,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
