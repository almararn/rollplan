import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/production_roll.dart';
import 'insert_checklist.dart';
import 'roll_card.dart';

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
                  RollCard(roll: currentRoll!, previousRoll: null)
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
      bool isHovered = false;
      cards.add(
        StatefulBuilder(
          builder: (context, setState) {
            return InkWell(
              onTap: () => _showInsertChecklistModal(
                  context, rolls[i], currentRoll), // Pass rolls
              onHover: (hovered) => setState(() => isHovered = hovered),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: isHovered
                    ? Matrix4.identity().scaled(1.03)
                    : Matrix4.identity(),
                child: RollCard(roll: rolls[i], previousRoll: previousRoll),
              ),
            );
          },
        ),
      );
    }
    return cards;
  }

  void _showInsertChecklistModal(BuildContext context, ProductionRoll nextRoll,
      ProductionRoll? currentRoll) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Roll Insert Checklist',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: InsertChecklist(
                    currentRoll: currentRoll, nextRoll: nextRoll), // Pass rolls
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Timestamp: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Insert'),
              onPressed: () {
                // Implement insert logic here, e.g., get checked items
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
