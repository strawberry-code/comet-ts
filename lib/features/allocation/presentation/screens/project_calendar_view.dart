import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/allocation_providers.dart';
import '../../domain/entities/allocation_entity.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../employee/presentation/providers/employee_providers.dart';
import '../../../employee/domain/entities/employee_entity.dart';

class ProjectCalendarView extends ConsumerStatefulWidget {
  final int projectId;
  
  const ProjectCalendarView({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectCalendarView> createState() => _ProjectCalendarViewState();
}

class _ProjectCalendarViewState extends ConsumerState<ProjectCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<AllocationEntity> _selectedDayAllocations = [];
  List<AllocationEntity> _projectAllocations = [];
  String _projectName = '';
  int _projectBudget = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    // Load project info
    final projectResult = await ref.read(projectRepositoryProvider).getProject(widget.projectId);
    projectResult.fold(
      (failure) => print('Error loading project: ${failure.message}'),
      (project) {
        if (project != null) {
          setState(() {
            _projectName = project.name;
            _projectBudget = project.budget;
          });
        }
      },
    );

    // Load allocations for this project
    final result = await ref.read(allocationRepositoryProvider).getAllocationsByProject(widget.projectId);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading allocations: ${failure.message}')),
        );
      },
      (allocations) {
        setState(() {
          _projectAllocations = allocations;
          _selectedDayAllocations = _getEventsForDay(_selectedDay);
        });
      },
    );
    
    // Load employees for display
    ref.invalidate(employeesListProvider);
  }

  List<AllocationEntity> _getEventsForDay(DateTime day) {
    return _projectAllocations.where((allocation) {
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
    
    // For project view, show different colors based on number of people allocated
    final uniqueEmployees = allocations.map((a) => a.employeeId).toSet().length;
    
    if (uniqueEmployees >= 4) return Colors.red; // Many people
    if (uniqueEmployees >= 3) return Colors.orange; // Several people
    if (uniqueEmployees >= 2) return Colors.yellow[700]!; // Some people
    return Colors.green; // One person
  }

  int _getUniqueEmployeesForDay(DateTime day) {
    final allocations = _getEventsForDay(day);
    return allocations.map((a) => a.employeeId).toSet().length;
  }

  double _getTotalHoursForDay(DateTime day) {
    final allocations = _getEventsForDay(day);
    final totalMinutes = allocations.fold<int>(0, (sum, allocation) => sum + allocation.hours);
    return totalMinutes / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_projectName.isNotEmpty ? _projectName : 'Project Calendar'),
            if (_projectName.isNotEmpty)
              Text(
                'Team Allocation Calendar',
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
            onPressed: () => context.go('/allocations/add?projectId=${widget.projectId}'),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () => _showBudgetInfo(),
          ),
        ],
      ),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading employees: $error')),
        data: (employees) => Column(
          children: [
            // Project Summary Card
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.groups,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team Overview',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total allocations: ${_projectAllocations.length}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<int?>(
                      future: ref.read(allocationProvider.notifier).getProjectBudgetRemaining(widget.projectId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final remaining = snapshot.data! / 100.0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Budget',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '€${remaining.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: remaining > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
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
                    
                    final employeeCount = _getUniqueEmployeesForDay(date);
                    
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: _getEventMarkerColor(date),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${employeeCount}p',
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
                            'No team allocations on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/allocations/add?projectId=${widget.projectId}'),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Team for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_getTotalHoursForDay(_selectedDay).toStringAsFixed(1)}h total',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _selectedDayAllocations.length,
                            itemBuilder: (context, index) {
                              final allocation = _selectedDayAllocations[index];
                              final employee = employees.firstWhere(
                                (e) => e.id == allocation.employeeId,
                                orElse: () => const EmployeeEntity(
                                  id: -1, 
                                  name: 'Unknown Employee', 
                                  levelId: -1,
                                ),
                              );

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Text(
                                      employee.name.isNotEmpty 
                                          ? employee.name[0].toUpperCase()
                                          : 'E',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    employee.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${allocation.hoursAsDecimal.toStringAsFixed(1)} hours allocated',
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
        onPressed: () => context.go('/allocations/add?projectId=${widget.projectId}'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBudgetInfo() async {
    final remainingBudget = await ref.read(allocationProvider.notifier).getProjectBudgetRemaining(widget.projectId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$_projectName - Budget Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Budget: €${(_projectBudget / 100).toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Remaining: €${((remainingBudget ?? 0) / 100).toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Used: €${((_projectBudget - (remainingBudget ?? 0)) / 100).toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: remainingBudget != null ? (_projectBudget - remainingBudget) / _projectBudget : 1.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                remainingBudget != null && remainingBudget > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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