import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ColorPickerRow extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.kHabitPalette.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final colorValue = AppColors.kHabitPalette[index];
          final isSelected = colorValue == selectedColor;
          return GestureDetector(
            onTap: () => onColorSelected(colorValue),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 48 : 40,
              height: isSelected ? 48 : 40,
              decoration: BoxDecoration(
                color: Color(colorValue),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(colorValue).withAlpha(100),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2.5)
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 20)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
