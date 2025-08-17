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

class AllocationListScreen extends ConsumerStatefulWidget {
  const AllocationListScreen({super.key});

  @override
  ConsumerState<AllocationListScreen> createState() => _AllocationListScreenState();
}

class _AllocationListScreenState extends ConsumerState<AllocationListScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<AllocationEntity> _selectedDayAllocations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    ref.read(allocationProvider.notifier).loadAllAllocations();
    // Projects and employees are loaded automatically by their respective providers
    ref.invalidate(projectsListProvider);
    ref.invalidate(employeesListProvider);
  }

  List<AllocationEntity> _getEventsForDay(DateTime day) {
    final allAllocations = ref.watch(allocationProvider).allocations;
    return allAllocations.where((allocation) {
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
    if (totalHoursDecimal >= 4.0) return Colors.orange; // Partially allocated
    return Colors.green; // Lightly allocated
  }

  @override
  Widget build(BuildContext context) {
    final allocationState = ref.watch(allocationProvider);
    final projectsAsync = ref.watch(projectsListProvider);
    final employeesAsync = ref.watch(employeesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/allocations/add'),
          ),
        ],
      ),
      body: allocationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (projects) => employeesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (employees) => Column(
              children: [
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
                                onPressed: () => context.go('/allocations/add'),
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
        onPressed: () => context.go('/allocations/add'),
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
                setState(() {
                  _selectedDayAllocations = _getEventsForDay(_selectedDay);
                });
                
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