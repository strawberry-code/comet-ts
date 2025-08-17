import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class RangeCalendarWidget extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onRangeSelected;
  final Function(bool) onRangeModeChanged;

  const RangeCalendarWidget({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onRangeSelected,
    required this.onRangeModeChanged,
  });

  @override
  State<RangeCalendarWidget> createState() => _RangeCalendarWidgetState();
}

class _RangeCalendarWidgetState extends State<RangeCalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialStartDate;
    _rangeEnd = widget.initialEndDate;
    if (_rangeStart != null || _rangeEnd != null) {
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Range Mode Toggle
            Row(
              children: [
                const Text(
                  'Date Selection Mode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Switch(
                  value: _rangeSelectionMode == RangeSelectionMode.toggledOn,
                  onChanged: (enabled) {
                    setState(() {
                      _rangeSelectionMode = enabled 
                          ? RangeSelectionMode.toggledOn 
                          : RangeSelectionMode.toggledOff;
                      
                      if (!enabled) {
                        _rangeStart = null;
                        _rangeEnd = null;
                      }
                    });
                    widget.onRangeModeChanged(enabled);
                    widget.onRangeSelected(_rangeStart, _rangeEnd);
                  },
                ),
              ],
            ),
            
            Text(
              _rangeSelectionMode == RangeSelectionMode.toggledOn
                  ? 'Range Mode: Select start and end dates'
                  : 'Single Mode: Select one date',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selected Range Display
            if (_rangeSelectionMode == RangeSelectionMode.toggledOn) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_rangeStart != null && _rangeEnd != null) ...[
                      Text('From: ${_formatDate(_rangeStart!)}'),
                      Text('To: ${_formatDate(_rangeEnd!)}'),
                      Text(
                        'Duration: ${_calculateDays(_rangeStart!, _rangeEnd!)} day(s)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ] else if (_rangeStart != null) ...[
                      Text('Start: ${_formatDate(_rangeStart!)}'),
                      Text(
                        'Select end date',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ] else ...[
                      Text(
                        'Select start date',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Calendar
            TableCalendar<dynamic>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              rangeSelectionMode: _rangeSelectionMode,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red[400]),
                rangeHighlightColor: Colors.blue[200]!,
                rangeStartDecoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                ),
                withinRangeDecoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange[400],
                  shape: BoxShape.circle,
                ),
              ),
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _rangeStart = start;
                  _rangeEnd = end;
                  _focusedDay = focusedDay;
                });
                widget.onRangeSelected(start, end);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
                  setState(() {
                    _rangeStart = selectedDay;
                    _rangeEnd = null;
                    _focusedDay = focusedDay;
                  });
                  widget.onRangeSelected(selectedDay, null);
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
            
            // Quick Range Buttons
            if (_rangeSelectionMode == RangeSelectionMode.toggledOn) ...[
              const SizedBox(height: 16),
              const Text(
                'Quick Select',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickRangeButton('This Week', _getThisWeekRange()),
                  _buildQuickRangeButton('Next Week', _getNextWeekRange()),
                  _buildQuickRangeButton('This Month', _getThisMonthRange()),
                  _buildQuickRangeButton('Clear', null),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRangeButton(String label, Map<String, DateTime>? range) {
    return OutlinedButton(
      onPressed: () {
        if (range == null) {
          // Clear selection
          setState(() {
            _rangeStart = null;
            _rangeEnd = null;
          });
        } else {
          setState(() {
            _rangeStart = range['start'];
            _rangeEnd = range['end'];
            _focusedDay = range['start']!;
          });
        }
        widget.onRangeSelected(_rangeStart, _rangeEnd);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Map<String, DateTime> _getThisWeekRange() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return {
      'start': DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      'end': DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    };
  }

  Map<String, DateTime> _getNextWeekRange() {
    final today = DateTime.now();
    final startOfNextWeek = today.add(Duration(days: 7 - today.weekday + 1));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
    
    return {
      'start': DateTime(startOfNextWeek.year, startOfNextWeek.month, startOfNextWeek.day),
      'end': DateTime(endOfNextWeek.year, endOfNextWeek.month, endOfNextWeek.day),
    };
  }

  Map<String, DateTime> _getThisMonthRange() {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    final endOfMonth = DateTime(today.year, today.month + 1, 0);
    
    return {
      'start': startOfMonth,
      'end': endOfMonth,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateDays(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }
}