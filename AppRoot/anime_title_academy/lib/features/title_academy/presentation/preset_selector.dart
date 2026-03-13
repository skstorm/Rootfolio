import 'package:flutter/material.dart';

class PresetSelector extends StatelessWidget {
  final List<String> presetNames;
  final String selectedPreset;
  final Function(String) onSelected;

  const PresetSelector({
    super.key,
    required this.presetNames,
    required this.selectedPreset,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: presetNames.length,
        itemBuilder: (context, index) {
          final preset = presetNames[index];
          final isSelected = preset == selectedPreset;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(preset),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelected(preset);
              },
            ),
          );
        },
      ),
    );
  }
}
