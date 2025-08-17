import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/allocation_providers.dart';
import '../../domain/entities/allocation_entity.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../employee/presentation/providers/employee_providers.dart';
import '../../../project/domain/entities/project_entity.dart';

class EmployeeCalendarView extends ConsumerStatefulWidget {
  final int employeeId;
  
  const EmployeeCalendarView({
    super.key,
    required this.employeeId,
  });

  @override
  ConsumerState<EmployeeCalendarView> createState() => _EmployeeCalendarViewState();
}

class _EmployeeCalendarViewState extends ConsumerState<EmployeeCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<AllocationEntity> _selectedDayAllocations = [];
  List<AllocationEntity> _employeeAllocations = [];
  String _employeeName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    // Load employee info
    final employeeResult = await ref.read(employeeRepositoryProvider).getEmployee(widget.employeeId);
    employeeResult.fold(
      (failure) => print('Error loading employee: ${failure.message}'),
      (employee) {
        if (employee != null) {
          setState(() {
            _employeeName = employee.name;
          });
        }
      },
    );

    // Load allocations for this employee
    final result = await ref.read(allocationRepositoryProvider).getAllocationsByEmployee(widget.employeeId);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading allocations: ${failure.message}')),
        );
      },
      (allocations) {
        setState(() {
          _employeeAllocations = allocations;
          _selectedDayAllocations = _getEventsForDay(_selectedDay);
        });
      },
    );
    
    // Load projects for display
    ref.invalidate(projectsListProvider);
  }

  List<AllocationEntity> _getEventsForDay(DateTime day) {
    return _employeeAllocations.where((allocation) {
      final allocationDate = DateTime(
        allocation.date.year,
        allocation.date.month,
        allocation.date.day,
      );
      final targetDate = DateTime(day.year, day.month, day.day);
      return allocationDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  Color _getEventMarkerColor(DateTime day) {
    final allocations = _getEventsForDay(day);
    if (allocations.isEmpty) return Colors.transparent;
    
    final totalHours = allocations.fold<int>(0, (sum, allocation) => sum + allocation.hours);
    final totalHoursDecimal = totalHours / 60.0;
    
    if (totalHoursDecimal >= 8.0) return Colors.red; // Fully allocated
    if (totalHoursDecimal >= 6.0) return Colors.orange; // Heavily allocated
    if (totalHoursDecimal >= 4.0) return Colors.yellow[700]!; // Moderately allocated
    return Colors.green; // Lightly allocated
  }

  double _getTotalHoursForDay(DateTime day) {
    final allocations = _getEventsForDay(day);
    final totalMinutes = allocations.fold<int>(0, (sum, allocation) => sum + allocation.hours);
    return totalMinutes / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_employeeName.isNotEmpty ? _employeeName : 'Employee Calendar'),
            if (_employeeName.isNotEmpty)
              Text(
                'Allocation Calendar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/allocations/add?employeeId=${widget.employeeId}'),
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading projects: $error')),
        data: (projects) => Column(
          children: [
            // Monthly Summary Card
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Overview',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total allocations: ${_employeeAllocations.length}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Calendar
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TableCalendar<AllocationEntity>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.red[400]),
                  holidayTextStyle: TextStyle(color: Colors.red[400]),
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedDayAllocations = _getEventsForDay(selectedDay);
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox();
                    
                    final hours = _getTotalHoursForDay(date);
                    
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: _getEventMarkerColor(date),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${hours.toStringAsFixed(1)}h',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Selected Day Details
            Expanded(
              child: _selectedDayAllocations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No allocations on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/allocations/add?employeeId=${widget.employeeId}'),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Allocation'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Allocations for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _selectedDayAllocations.length,
                            itemBuilder: (context, index) {
                              final allocation = _selectedDayAllocations[index];
                              final project = projects.firstWhere(
                                (p) => p.id == allocation.projectId,
                                orElse: () => const ProjectEntity(
                                  id: -1, 
                                  name: 'Unknown Project', 
                                  budget: 0, 
                                  startDate: 0, 
                                  endDate: 0,
                                ),
                              );

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      project.name.isNotEmpty 
                                          ? project.name[0].toUpperCase()
                                          : 'P',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    project.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${allocation.hoursAsDecimal.toStringAsFixed(1)} hours',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => context.go('/allocations/edit/${allocation.id}'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _showDeleteDialog(allocation),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/allocations/add?employeeId=${widget.employeeId}'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(AllocationEntity allocation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Allocation'),
        content: const Text('Are you sure you want to delete this allocation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(allocationProvider.notifier)
                  .deleteExistingAllocation(allocation.id!);
              
              if (success) {
                _loadData(); // Reload data
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Allocation deleted successfully')),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ref.read(allocationProvider).errorMessage ?? 'Failed to delete allocation'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}