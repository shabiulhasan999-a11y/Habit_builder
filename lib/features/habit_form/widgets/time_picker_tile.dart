import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class TimePickerTile extends StatefulWidget {
  final String? initialTime;
  final ValueChanged<String?> onTimeChanged;

  const TimePickerTile({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<TimePickerTile> createState() => _TimePickerTileState();
}

class _TimePickerTileState extends State<TimePickerTile> {
  bool _enabled = false;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    _applyInitialTime(widget.initialTime);
  }

  @override
  void didUpdateWidget(TimePickerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTime != oldWidget.initialTime) {
      setState(() => _applyInitialTime(widget.initialTime));
    }
  }

  void _applyInitialTime(String? time) {
    if (time != null) {
      _enabled = true;
      final parts = time.split(':');
      if (parts.length == 2) {
        _time = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    } else {
      _enabled = false;
      _time = null;
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF13131A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _time = picked);
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      widget.onTimeChanged('$h:$m');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kGlassWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.kGlassBorder),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: _enabled,
            onChanged: (val) {
              setState(() {
                _enabled = val;
                if (!val) {
                  _time = null;
                  widget.onTimeChanged(null);
                } else {
                  _time ??= const TimeOfDay(hour: 8, minute: 0);
                  final h = _time!.hour.toString().padLeft(2, '0');
                  final m = _time!.minute.toString().padLeft(2, '0');
                  widget.onTimeChanged('$h:$m');
                }
              });
            },
            title: const Text('Daily Reminder', style: AppTextStyles.bodyMedium),
            subtitle: Text(
              'Get notified to complete this habit',
              style: AppTextStyles.caption,
            ),
            secondary: const Icon(
              Icons.notifications_rounded,
              color: AppColors.kAccentPrimary,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          if (_enabled) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(
                Icons.access_time_rounded,
                color: AppColors.kTextSecondary,
              ),
              title: Text(
                _time != null ? _formatTime(_time!) : 'Set time',
                style: AppTextStyles.bodyMedium,
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.kTextDisabled,
              ),
              onTap: _pickTime,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }
}
