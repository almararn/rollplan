import 'package:flutter/material.dart';
import '../models/production_roll.dart';
import '../services/data_service.dart';

class InsertChecklist extends StatefulWidget {
  final ProductionRoll? currentRoll;
  final ProductionRoll nextRoll;

  const InsertChecklist({super.key, required this.nextRoll, this.currentRoll});

  @override
  InsertChecklistState createState() => InsertChecklistState();
}

class InsertChecklistState extends State<InsertChecklist> {
  late List<String> checklistItems;
  late List<bool> checkedItems;
  String? selectedShift;
  TextEditingController operatorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checklistItems = _generateChecklist();
    checkedItems = List.generate(checklistItems.length, (index) => false);
  }

  List<String> _generateChecklist() {
    List<String> items = [];

    items.add(
      'Confirm the roll number is correct: ${widget.nextRoll.rollNumber}',
    );

    if (widget.currentRoll != null) {
      if (areRollsSame(widget.currentRoll!, widget.nextRoll)) {
        items.add(
            'This roll is the same as the previous VIP roll and requires no changes');
      } else {
        double currentVF = double.parse(widget.nextRoll.finalProd
            .split('/')
            .last
            .replaceAll(RegExp(r'[^0-9.]'), ''));
        double previousVF = double.parse(widget.currentRoll!.finalProd
            .split('/')
            .last
            .replaceAll(RegExp(r'[^0-9.]'), ''));
        double vfDiff = currentVF - previousVF;

        int currentSpeedC = int.parse(widget.nextRoll.speedC);
        int previousSpeedC = int.parse(widget.currentRoll!.speedC);
        int speedDiff = currentSpeedC - previousSpeedC;

        String vfDiffString =
            (vfDiff > 0 ? '+' : '') + vfDiff.toStringAsFixed(1);
        String speedDiffString =
            (speedDiff > 0 ? '+' : '') + speedDiff.toString();

        items.add(
            'This roll has a change of $vfDiffString V and $speedDiffString cm/min from the current VIP roll, confirm those changes and check if trafo tap is correct');
      }
    } else {
      items.add('Confirm first roll parameters');
    }

    items.addAll([
      'The alignment in the machine is okay?',
      'The roll is undamaged?',
      'You have verified all parameters for this roll?',
      'You have read the quality notes and checked if this is a trial roll?',
    ]);

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            checklistItems.length,
            (index) => CheckboxListTile(
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: _buildRichText(checklistItems[index], index == 0),
                ),
              ),
              value: checkedItems[index],
              onChanged: (bool? value) {
                setState(() {
                  checkedItems[index] = value!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: DropdownButtonFormField<String>(
                value: selectedShift,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedShift = newValue;
                  });
                },
                items: <String>[
                  'Shift-A',
                  'Shift-B',
                  'Shift-C',
                  'Shift-D',
                  'Shift-E'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Shift'),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextFormField(
                controller: operatorController,
                decoration: const InputDecoration(labelText: 'Operator Name'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<TextSpan> _buildRichText(String text, bool isFirst) {
    RegExp exp = RegExp(r'([+-]?\d+\.?\d* V)|([+-]?\d+ cm/min)');
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    List<TextSpan> spans = [];
    int currentIndex = 0;

    if (isFirst) {
      List<String> parts = text.split(': ');
      if (parts.length == 2) {
        spans.add(TextSpan(text: '${parts[0]}: '));
        spans.add(TextSpan(
            text: parts[1], style: TextStyle(fontWeight: FontWeight.bold)));
      } else {
        spans.add(TextSpan(text: text));
      }
      return spans;
    }

    for (RegExpMatch match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      spans.add(TextSpan(
          text: match.group(0),
          style: const TextStyle(fontWeight: FontWeight.bold)));
      currentIndex = match.end;
    }
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }
    return spans;
  }
}
