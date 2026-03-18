import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class EmojiPickerField extends StatelessWidget {
  final String selectedEmoji;
  final int selectedColor;
  final ValueChanged<String> onEmojiSelected;

  const EmojiPickerField({
    super.key,
    required this.selectedEmoji,
    required this.selectedColor,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEmojiPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.kGlassWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.kGlassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(selectedColor).withAlpha(38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  selectedEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Choose an icon',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.kTextSecondary),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.kTextDisabled,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose Icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: AppColors.kHabitEmojis.length,
            itemBuilder: (context, index) {
              final emoji = AppColors.kHabitEmojis[index];
              final isSelected = emoji == selectedEmoji;
              return GestureDetector(
                onTap: () {
                  onEmojiSelected(emoji);
                  Navigator.pop(ctx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(selectedColor).withAlpha(51)
                        : AppColors.kGlassWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: Color(selectedColor), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
