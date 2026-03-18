import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import 'widgets/color_picker_row.dart';
import 'widgets/emoji_picker_field.dart';
import 'widgets/time_picker_tile.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  final String? habitId;
  const HabitFormScreen({super.key, this.habitId});

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _selectedColor = AppColors.kHabitPalette.first;
  String _selectedEmoji = '🎯';
  String? _reminderTime;
  bool _isLoading = false;

  Habit? _editingHabit;
  bool get _isEditing => widget.habitId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // Read directly in initState so TimePickerTile sees the correct
      // initialTime on its very first build (no addPostFrameCallback race).
      final habit = ref.read(habitByIdProvider(widget.habitId!));
      if (habit != null) {
        _editingHabit = habit;
        _nameController.text = habit.name;
        _selectedColor = habit.colorValue;
        _selectedEmoji = habit.icon;
        _reminderTime = habit.reminderTime;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditing && _editingHabit != null) {
        final updated = _editingHabit!.copyWith(
          name: _nameController.text.trim(),
          colorValue: _selectedColor,
          icon: _selectedEmoji,
          reminderTime: _reminderTime,
          clearReminder: _reminderTime == null,
        );
        await ref.read(habitProvider.notifier).updateHabit(updated);
      } else {
        await ref.read(habitProvider.notifier).addHabit(
              name: _nameController.text.trim(),
              colorValue: _selectedColor,
              icon: _selectedEmoji,
              reminderTime: _reminderTime,
            );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'New Habit'),
        backgroundColor: AppColors.kBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            _SectionLabel('Habit Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              autofocus: !_isEditing,
              maxLength: 40,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'e.g. Morning Run',
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            _SectionLabel('Color'),
            const SizedBox(height: 12),
            ColorPickerRow(
              selectedColor: _selectedColor,
              onColorSelected: (c) => setState(() => _selectedColor = c),
            ),
            const SizedBox(height: 28),
            _SectionLabel('Icon'),
            const SizedBox(height: 8),
            EmojiPickerField(
              selectedEmoji: _selectedEmoji,
              selectedColor: _selectedColor,
              onEmojiSelected: (e) => setState(() => _selectedEmoji = e),
            ),
            const SizedBox(height: 28),
            _SectionLabel('Reminder'),
            const SizedBox(height: 8),
            TimePickerTile(
              initialTime: _reminderTime,
              onTimeChanged: (t) => setState(() => _reminderTime = t),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _SaveButton(
                  label: _isEditing ? 'Save Changes' : 'Add Habit',
                  color: Color(_selectedColor),
                  onPressed: _save,
                ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withAlpha(204)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
