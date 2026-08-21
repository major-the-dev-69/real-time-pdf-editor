import 'package:flutter/material.dart';

Future<Color> showColorPicker(BuildContext context, Color currentColor) async {
  Color pickedColor = currentColor;
  final List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pick a Color'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((color) {
                  final isSelected = pickedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        pickedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Select'),
              ),
            ],
          );
        },
      );
    },
  );
  return pickedColor;
}

