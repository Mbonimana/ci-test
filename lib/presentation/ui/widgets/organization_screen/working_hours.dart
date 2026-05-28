import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_form_lable.dart';

class TimeRange {
  TimeOfDay? open;
  TimeOfDay? close;
  TimeRange({this.open, this.close});
}

class WorkingHours extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaved;

  // Added initial values parameters so the widget can remember and restore state
  final bool initialIsActive;
  final bool initialIsOpen24;
  final bool initialIsTempClosed;
  final String? initialPossibleReturnDate;

  const WorkingHours({
    super.key,
    required this.onSaved,
    this.initialIsActive = false,
    this.initialIsOpen24 = false,
    this.initialIsTempClosed = false,
    this.initialPossibleReturnDate,
  });

  @override
  State<WorkingHours> createState() => _WorkingHoursState();
}

class _WorkingHoursState extends State<WorkingHours> {
  late bool isActive;
  late bool isOpen24;
  late bool isTempClosed;
  bool isExpanded = false;
  String? reportSummary;
  TimeOfDay? globalOpen = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? globalClose = const TimeOfDay(hour: 17, minute: 0);
  DateTime? possibleReturnDate;

  final Map<int, List<TimeRange>> _weeklyHours = {
    for (var i = 1; i <= 7; i++)
      i: [
        TimeRange(
          open: const TimeOfDay(hour: 9, minute: 0),
          close: const TimeOfDay(hour: 17, minute: 0),
        ),
      ],
  };

  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    // Initialize state from widget properties
    isActive = widget.initialIsActive;
    isOpen24 = widget.initialIsOpen24;
    isTempClosed = widget.initialIsTempClosed;

    if (widget.initialPossibleReturnDate != null) {
      possibleReturnDate = DateTime.tryParse(widget.initialPossibleReturnDate!);
    }

    _syncState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncToParent());
  }

  String _format(TimeOfDay? t) {
    if (t == null) return "--:--";
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "--/--/----";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Output keys synchronized with backend snake_case keys
  void _syncToParent() {
    Map<String, dynamic> jsonOutput = {
      "is_active": isActive,
      "is_open_24_hours": isOpen24,
      "is_temporary_closed": isTempClosed,
      "possible_return_date": isTempClosed
          ? _formatDate(possibleReturnDate)
          : null,
      "weekly_hours": {},
    };

    _weeklyHours.forEach((day, ranges) {
      String dayName = _days[day - 1];
      if (ranges.isEmpty) {
        jsonOutput["weekly_hours"][dayName] = "Closed";
      } else {
        jsonOutput["weekly_hours"][dayName] = ranges
            .map((r) => {"open": _format(r.open), "close": _format(r.close)})
            .toList();
      }
    });

    widget.onSaved(jsonOutput);
  }

  void _confirm() {
    StringBuffer report = StringBuffer();
    _weeklyHours.forEach((day, ranges) {
      String dayName = _days[day - 1];
      if (ranges.isEmpty) {
        report.writeln("$dayName: Closed");
      } else {
        String times = ranges
            .map((r) => "${_format(r.open)} – ${_format(r.close)}")
            .join(", ");
        report.writeln("$dayName: $times");
      }
    });

    _syncToParent();
    setState(() {
      reportSummary = report.toString();
      isExpanded = false;
    });
  }

  void _syncState() {
    if (isTempClosed) {
      _weeklyHours.updateAll((key, value) => []);
    } else if (isOpen24) {
      _weeklyHours.updateAll(
        (key, value) => [
          TimeRange(
            open: const TimeOfDay(hour: 0, minute: 0),
            close: const TimeOfDay(hour: 23, minute: 59),
          ),
        ],
      );
    }
    _syncToParent();
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;
  bool _isAfter(TimeOfDay left, TimeOfDay right) =>
      _minutes(left) > _minutes(right);

  TimeOfDay _advance(TimeOfDay time, int minutes) {
    final int totalMinutes = (_minutes(time) + minutes).clamp(0, 23 * 60 + 59);
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  TimeOfDay _nextAllowedSlot(TimeOfDay time) {
    final int nextQuarter = ((_minutes(time) ~/ 15) + 1) * 15;
    return _advance(const TimeOfDay(hour: 0, minute: 0), nextQuarter);
  }

  Future<TimeOfDay?> _pickTime({
    required TimeOfDay initialTime,
    TimeOfDay? minTime,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && minTime != null && !_isAfter(picked, minTime)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text("Time must be after previous shift."),
          ),
        );
      }
      return null;
    }
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            checkbox("Active", isActive, (v) {
              setState(() => isActive = v!);
              _syncToParent();
            }),
            checkbox("Open 24hr", isOpen24, (v) {
              setState(() {
                isOpen24 = v!;
                if (isOpen24) isTempClosed = false;
                _syncState();
              });
            }),
          ],
        ),
        Row(
          children: [
            checkbox("Temporarily Closed", isTempClosed, (v) {
              setState(() {
                isTempClosed = v!;
                if (isTempClosed) isOpen24 = false;
                _syncState();
              });
            }),
          ],
        ),
        if (isTempClosed) ...[
          AppFormLable(text: "Possible return date (optional)"),
          SizedBox(height: 12.h),
          dateBox(possibleReturnDate, (date) {
            setState(() => possibleReturnDate = date);
            _syncToParent();
          }),
        ],

        buildDefaultRow(),
        SizedBox(height: 15.h),
        if (reportSummary != null && !isExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              reportSummary!,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        if (isExpanded) ...[
          SizedBox(height: 10.h),
          ...List.generate(7, (i) => buildDayRow(i + 1, _days[i])),
          const SizedBox(height: 20),
          SizedBox(
            width: 120,
            height: 40,
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(
                  color: AppColors.backgroundBase,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ],
    );
  }

  Widget buildDefaultRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormLable(text: "Open at"),
            SizedBox(height: 15.h),
            timeBox(
              globalOpen,
              isOpen24 || isTempClosed
                  ? null
                  : (t) {
                      setState(() => globalOpen = t);
                      _syncState();
                    },
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text("-"),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormLable(text: "Close at"),
            SizedBox(height: 15.h),
            timeBox(
              globalClose,
              isOpen24 || isTempClosed
                  ? null
                  : (t) {
                      setState(() => globalClose = t);
                      _syncState();
                    },
              minTime: globalOpen,
            ),
          ],
        ),
        const SizedBox(width: 15),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            onTap: () => setState(() {
              isExpanded = !isExpanded;
              if (isExpanded) reportSummary = null;
            }),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.brandPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpanded ? Icons.remove : Icons.add,
                color: AppColors.buttonTextPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDayRow(int day, String name) {
    bool active = _weeklyHours[day]!.isNotEmpty;
    return Opacity(
      opacity: isTempClosed ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 45,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  if (!active)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Closed",
                          style: AppTypography.captionSmall,
                        ),
                      ),
                    ),
                  ..._weeklyHours[day]!.asMap().entries.map((entry) {
                    int idx = entry.key;
                    TimeRange r = entry.value;
                    final TimeOfDay? previousClose = idx > 0
                        ? _weeklyHours[day]![idx - 1].close
                        : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          timeBox(
                            r.open,
                            isTempClosed || isOpen24
                                ? null
                                : (t) {
                                    setState(() => r.open = t);
                                    _syncToParent();
                                  },
                            minTime: previousClose,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text("-"),
                          ),
                          timeBox(
                            r.close,
                            isTempClosed || isOpen24
                                ? null
                                : (t) {
                                    setState(() => r.close = t);
                                    _syncToParent();
                                  },
                            minTime: r.open,
                          ),
                          SizedBox(width: 8.h),

                          if (idx == 0 && !isOpen24 && !isTempClosed)
                            GestureDetector(
                              onTap: () => setState(() {
                                final prevClose = r.close ?? globalClose;
                                final newOpen = _nextAllowedSlot(prevClose!);
                                _weeklyHours[day]!.add(
                                  TimeRange(
                                    open: newOpen,
                                    close: _nextAllowedSlot(newOpen),
                                  ),
                                );
                                _syncToParent();
                              }),
                              child: Text(
                                "+ Add",
                                style: AppTypography.captionSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brandPrimary,
                                ),
                              ),
                            ),
                          if (idx > 0 && !isOpen24 && !isTempClosed)
                            GestureDetector(
                              onTap: () => setState(() {
                                _weeklyHours[day]!.removeAt(idx);
                                _syncToParent();
                              }),
                              child: const Icon(
                                Icons.remove_circle_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            toggle(active, (val) {
              setState(
                () => _weeklyHours[day] = val
                    ? [
                        TimeRange(
                          open: const TimeOfDay(hour: 9, minute: 0),
                          close: const TimeOfDay(hour: 17, minute: 0),
                        ),
                      ]
                    : [],
              );
              _syncToParent();
            }),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget checkbox(String title, bool value, Function(bool?) onChanged) =>
      Expanded(
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.brandPrimary,
              side: const BorderSide(width: 2, color: AppColors.brandPrimary),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
  Widget toggle(bool active, Function(bool) onChange) => GestureDetector(
    onTap: isTempClosed ? null : () => onChange(!active),
    child: Container(
      width: 34,
      height: 20,
      decoration: BoxDecoration(
        color: active ? AppColors.brandPrimary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(2),
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: AppColors.buttonTextPrimary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
  Widget timeBox(
    TimeOfDay? time,
    Function(TimeOfDay)? onPick, {
    TimeOfDay? minTime,
  }) => InkWell(
    onTap: onPick == null
        ? null
        : () async {
            final TimeOfDay? picked = await _pickTime(
              initialTime: time ?? TimeOfDay.now(),
              minTime: minTime,
            );
            if (picked != null) onPick(picked);
          },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: onPick == null ? Colors.grey.shade200 : const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        _format(time),
        style: TextStyle(
          fontSize: 12,
          color: onPick == null ? Colors.grey : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
  Widget dateBox(DateTime? date, Function(DateTime) onPick) => InkWell(
    onTap: () async {
      final DateTime now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date ?? now,
        firstDate: now,
        lastDate: DateTime(now.year + 5),
      );
      if (picked != null) onPick(picked);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        _formatDate(date),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
