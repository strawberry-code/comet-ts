import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/allocation_providers.dart';
import '../widgets/allocation_summary_card.dart';
import '../widgets/allocation_list_item.dart';
import '../../domain/entities/allocation_entity.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../employee/presentation/providers/employee_providers.dart';

class ProjectAllocationListScreen extends ConsumerStatefulWidget {
  final int projectId;
  
  const ProjectAllocationListScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectAllocationListScreen> createState() => _ProjectAllocationListScreenState();
}

class _ProjectAllocationListScreenState extends ConsumerState<ProjectAllocationListScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<AllocationEntity> _selectedDayAllocations = [];
  List<AllocationEntity> _projectAllocations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjectAllocations();
    });
  }

  void _loadProjectAllocations() async {
    // Load allocations for this specific project
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
    
    // Also load projects and employees for display
    ref.invalidate(projectsListProvider);
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
    
    if (uniqueEmployees >= 3) return Colors.red; // Many people
    if (uniqueEmployees >= 2) return Colors.orange; // Some people
    return Colors.green; // One person
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListProvider);
    final employeesAsync = ref.watch(employeesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: ref.read(projectRepositoryProvider).getProject(widget.projectId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.fold(
                (failure) => const Text('Project Allocations'),
                (project) => Text('${project?.name ?? 'Unknown'} - Allocations'),
              );
            }
            return const Text('Project Allocations');
          },
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
          // Add budget info button
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () => _showBudgetInfo(),
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (projects) => employeesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (employees) => Column(
            children: [
              // Project Budget Summary
              _buildProjectBudgetSummary(),
              
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AllocationSummaryCard(
                  selectedDate: _selectedDay,
                  allocations: _selectedDayAllocations,
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
                      
                      return Container(
                        margin: const EdgeInsets.only(top: 5),
                        alignment: Alignment.center,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getEventMarkerColor(date),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Selected Day Allocations
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
                              'No allocations for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
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
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _selectedDayAllocations.length,
                        itemBuilder: (context, index) {
                          final allocation = _selectedDayAllocations[index];
                          return AllocationListItem(
                            allocation: allocation,
                            projects: projects,
                            employees: employees,
                            onTap: () => context.go('/allocations/edit/${allocation.id}'),
                            onDelete: () => _showDeleteDialog(allocation),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/allocations/add?projectId=${widget.projectId}'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectBudgetSummary() {
    return FutureBuilder<int?>(
      future: ref.read(allocationProvider.notifier).getProjectBudgetRemaining(widget.projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        final remainingBudget = snapshot.data! / 100.0; // Convert to euros
        
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: remainingBudget > 0 ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Budget Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Remaining: €${remainingBudget.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: remainingBudget > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBudgetInfo() async {
    final remainingBudget = await ref.read(allocationProvider.notifier).getProjectBudgetRemaining(widget.projectId);
    final project = await ref.read(projectRepositoryProvider).getProject(widget.projectId);
    
    project.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading project: ${failure.message}')),
      ),
      (proj) {
        if (proj == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project not found')),
          );
          return;
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${proj.name} - Budget Info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Budget: €${(proj.budget / 100).toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Remaining: €${((remainingBudget ?? 0) / 100).toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Used: €${((proj.budget - (remainingBudget ?? 0)) / 100).toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: remainingBudget != null ? (proj.budget - remainingBudget) / proj.budget : 1.0,
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
      },
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
                _loadProjectAllocations(); // Reload allocations
                
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