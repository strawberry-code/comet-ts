import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/allocation_providers.dart';
import '../widgets/budget_validation_dialog.dart';
import '../widgets/range_calendar_widget.dart';
import '../../domain/entities/allocation_entity.dart';
import '../../domain/entities/allocation_validation_result.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../employee/presentation/providers/employee_providers.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../employee/domain/entities/employee_entity.dart';

class AllocationDetailScreen extends ConsumerStatefulWidget {
  final int? allocationId;
  final int? preselectedEmployeeId;
  final int? preselectedProjectId;

  const AllocationDetailScreen({
    super.key, 
    this.allocationId,
    this.preselectedEmployeeId,
    this.preselectedProjectId,
  });

  @override
  ConsumerState<AllocationDetailScreen> createState() => _AllocationDetailScreenState();
}

class _AllocationDetailScreenState extends ConsumerState<AllocationDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;
  bool _isRangeMode = false;
  ProjectEntity? _selectedProject;
  EmployeeEntity? _selectedEmployee;
  AllocationEntity? _existingAllocation;
  
  bool _isLoading = false;
  String? _validationError;
  AllocationValidationResult? _lastValidation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() async {
    // Projects and employees are loaded automatically by their providers
    ref.invalidate(projectsListProvider);
    ref.invalidate(employeesListProvider);
    
    if (widget.allocationId != null) {
      await _loadExistingAllocation();
    } else {
      // Handle preselected values for new allocations
      await _handlePreselectedValues();
    }
  }

  Future<void> _handlePreselectedValues() async {
    if (widget.preselectedEmployeeId != null || widget.preselectedProjectId != null) {
      // Wait for providers to load
      await Future.delayed(const Duration(milliseconds: 100));
      
      final projectsAsync = ref.read(projectsListProvider);
      final employeesAsync = ref.read(employeesListProvider);
      
      projectsAsync.whenData((projects) {
        if (widget.preselectedProjectId != null) {
          final project = projects.firstWhere(
            (p) => p.id == widget.preselectedProjectId,
            orElse: () => const ProjectEntity(id: -1, name: '', budget: 0, startDate: 0, endDate: 0),
          );
          if (project.id != -1) {
            setState(() {
              _selectedProject = project;
            });
          }
        }
      });
      
      employeesAsync.whenData((employees) {
        if (widget.preselectedEmployeeId != null) {
          final employee = employees.firstWhere(
            (e) => e.id == widget.preselectedEmployeeId,
            orElse: () => const EmployeeEntity(id: -1, name: '', levelId: -1),
          );
          if (employee.id != -1) {
            setState(() {
              _selectedEmployee = employee;
            });
          }
        }
      });
    }
  }

  Future<void> _loadExistingAllocation() async {
    setState(() => _isLoading = true);
    
    final result = await ref.read(allocationRepositoryProvider).getAllocation(widget.allocationId!);
    
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _validationError = failure.message;
        });
      },
      (allocation) {
        setState(() {
          _existingAllocation = allocation;
          _selectedDate = allocation.date;
          _hoursController.text = allocation.hoursAsDecimal.toStringAsFixed(1);
          _isLoading = false;
        });
        
        // Project and employee selection will be handled in build method with async providers
      },
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListProvider);
    final employeesAsync = ref.watch(employeesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.allocationId != null ? 'Edit Allocation' : 'Add Allocation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/allocations'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error loading projects: $error')),
              data: (projects) => employeesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error loading employees: $error')),
                data: (employees) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Selection
                    const Text(
                      'Project',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ProjectEntity>(
                      value: _selectedProject,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select a project',
                      ),
                      items: projects.map((project) {
                        return DropdownMenuItem(
                          value: project,
                          child: FutureBuilder<int?>(
                            future: _getProjectRemainingBudget(project.id!),
                            builder: (context, snapshot) {
                              final budget = snapshot.data;
                              final budgetText = budget != null 
                                  ? ' (€${(budget / 100).toStringAsFixed(2)} remaining)'
                                  : '';
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Budget: €${(project.budget / 100).toStringAsFixed(2)}$budgetText',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: budget != null && budget <= 0 
                                          ? Colors.red 
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }).toList(),
                      onChanged: (project) {
                        setState(() {
                          _selectedProject = project;
                          _validationError = null;
                        });
                        _validateRealTime();
                      },
                      validator: (value) => value == null ? 'Please select a project' : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Employee Selection
                    const Text(
                      'Employee',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<EmployeeEntity>(
                      value: _selectedEmployee,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select an employee',
                      ),
                      items: employees.map((employee) {
                        return DropdownMenuItem(
                          value: employee,
                          child: Text(employee.name),
                        );
                      }).toList(),
                      onChanged: (employee) {
                        setState(() {
                          _selectedEmployee = employee;
                          _validationError = null;
                        });
                        _validateRealTime();
                      },
                      validator: (value) => value == null ? 'Please select an employee' : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date Selection with Range Calendar
                    const Text(
                      'Date Selection',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    RangeCalendarWidget(
                      initialStartDate: _isRangeMode ? _rangeStartDate : _selectedDate,
                      initialEndDate: _isRangeMode ? _rangeEndDate : null,
                      onRangeSelected: (start, end) {
                        setState(() {
                          if (_isRangeMode) {
                            _rangeStartDate = start;
                            _rangeEndDate = end;
                          } else {
                            _selectedDate = start ?? DateTime.now();
                          }
                          _validationError = null;
                        });
                        _validateRealTime();
                      },
                      onRangeModeChanged: (isRangeMode) {
                        setState(() {
                          _isRangeMode = isRangeMode;
                          if (!isRangeMode) {
                            _rangeStartDate = null;
                            _rangeEndDate = null;
                          }
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Hours Input
                    const Text(
                      'Hours',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter hours (e.g., 2.5)',
                        suffixText: 'hours',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        setState(() => _validationError = null);
                        _validateRealTime();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hours';
                        }
                        final hours = double.tryParse(value);
                        if (hours == null || hours <= 0) {
                          return 'Please enter a valid number of hours';
                        }
                        if (hours > 24) {
                          return 'Hours cannot exceed 24 per day';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Real-time Validation Display
                    if (_lastValidation != null && !_lastValidation!.isValid) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _lastValidation!.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_lastValidation!.maxAvailableHoursAsDecimal != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Maximum available: ${_lastValidation!.maxAvailableHoursAsDecimal!.toStringAsFixed(1)} hours',
                                style: TextStyle(color: Colors.red[600]),
                              ),
                            ],
                            if (_lastValidation!.availableBudgetAsEuros != null && 
                                _lastValidation!.requiredBudgetAsEuros != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Required: €${_lastValidation!.requiredBudgetAsEuros!.toStringAsFixed(2)} | Available: €${_lastValidation!.availableBudgetAsEuros!.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.red[600], fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Budget Information Display
                    if (_selectedProject != null && _selectedEmployee != null) ...[
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getBudgetInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data!;
                            final costPerHour = data['costPerHour'] as double;
                            final remainingBudget = data['remainingBudget'] as double;
                            final hours = double.tryParse(_hoursController.text) ?? 0;
                            final requiredBudget = hours * costPerHour;
                            
                            return Container(
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
                                    'Budget Calculation',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Employee cost: €${costPerHour.toStringAsFixed(2)}/hour'),
                                  Text('Required budget: €${requiredBudget.toStringAsFixed(2)}'),
                                  Text('Project remaining: €${remainingBudget.toStringAsFixed(2)}'),
                                  Text(
                                    'After allocation: €${(remainingBudget - requiredBudget).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: remainingBudget >= requiredBudget 
                                          ? Colors.green[700] 
                                          : Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/allocations'),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveAllocation,
                            child: Text(widget.allocationId != null ? 'Update' : 'Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
                ),
              ),
    );
  }


  Future<void> _validateRealTime() async {
    if (_selectedProject == null || _selectedEmployee == null || _hoursController.text.isEmpty) {
      return;
    }

    final hours = double.tryParse(_hoursController.text);
    if (hours == null || hours <= 0) return;

    final hoursInMinutes = (hours * 60).round();
    
    final validation = await ref.read(allocationProvider.notifier).validateAllocationData(
      projectId: _selectedProject!.id!,
      employeeId: _selectedEmployee!.id!,
      hours: hoursInMinutes,
      date: _selectedDate,
      excludeAllocationId: widget.allocationId,
    );

    setState(() {
      _lastValidation = validation;
    });
  }

  Future<void> _saveAllocation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProject == null || _selectedEmployee == null) return;

    final hours = double.parse(_hoursController.text);
    final hoursInMinutes = (hours * 60).round();

    // Handle range mode vs single date mode
    if (_isRangeMode && _rangeStartDate != null && _rangeEndDate != null) {
      await _saveRangeAllocations(hoursInMinutes);
    } else {
      await _saveSingleAllocation(hoursInMinutes);
    }
  }

  Future<void> _saveSingleAllocation(int hoursInMinutes) async {
    // Final validation before saving
    final validation = await ref.read(allocationProvider.notifier).validateAllocationData(
      projectId: _selectedProject!.id!,
      employeeId: _selectedEmployee!.id!,
      hours: hoursInMinutes,
      date: _selectedDate,
      excludeAllocationId: widget.allocationId,
    );

    if (validation != null && !validation.isValid) {
      await _showValidationDialog(validation, hoursInMinutes / 60.0);
      return;
    }

    setState(() => _isLoading = true);

    final allocation = AllocationEntity(
      id: widget.allocationId,
      projectId: _selectedProject!.id!,
      employeeId: _selectedEmployee!.id!,
      date: _selectedDate,
      hours: hoursInMinutes,
    );

    bool success;
    if (widget.allocationId != null) {
      success = await ref.read(allocationProvider.notifier).updateExistingAllocation(allocation);
    } else {
      success = await ref.read(allocationProvider.notifier).createNewAllocation(allocation);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.allocationId != null 
                  ? 'Allocation updated successfully' 
                  : 'Allocation created successfully',
            ),
          ),
        );
        context.go('/allocations');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(allocationProvider).errorMessage ?? 'Failed to save allocation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveRangeAllocations(int hoursInMinutes) async {
    final datesToAllocate = _generateDateRange(_rangeStartDate!, _rangeEndDate!);
    
    // Show confirmation dialog for bulk allocation
    final confirmed = await _showBulkAllocationDialog(datesToAllocate.length, hoursInMinutes / 60.0);
    if (!confirmed) return;

    setState(() => _isLoading = true);

    int successCount = 0;
    int failureCount = 0;
    List<String> errors = [];

    for (final date in datesToAllocate) {
      // Validate each allocation
      final validation = await ref.read(allocationProvider.notifier).validateAllocationData(
        projectId: _selectedProject!.id!,
        employeeId: _selectedEmployee!.id!,
        hours: hoursInMinutes,
        date: date,
      );

      if (validation != null && validation.isValid) {
        final allocation = AllocationEntity(
          projectId: _selectedProject!.id!,
          employeeId: _selectedEmployee!.id!,
          date: date,
          hours: hoursInMinutes,
        );

        final success = await ref.read(allocationProvider.notifier).createNewAllocation(allocation);
        if (success) {
          successCount++;
        } else {
          failureCount++;
          errors.add('${date.day}/${date.month}/${date.year}: Failed to create');
        }
      } else {
        failureCount++;
        errors.add('${date.day}/${date.month}/${date.year}: ${validation?.errorMessage ?? "Validation failed"}');
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount allocation(s) created successfully${failureCount > 0 ? ", $failureCount failed" : ""}'),
            backgroundColor: failureCount > 0 ? Colors.orange : Colors.green,
          ),
        );
        
        if (failureCount > 0) {
          _showErrorsDialog(errors);
        }
        
        context.go('/allocations');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All allocations failed. Check validation errors.'),
            backgroundColor: Colors.red,
          ),
        );
        _showErrorsDialog(errors);
      }
    }
  }

  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    
    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  Future<bool> _showBulkAllocationDialog(int dayCount, double hoursPerDay) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Allocation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to create allocations for:'),
            const SizedBox(height: 8),
            Text('• $dayCount day(s)'),
            Text('• ${hoursPerDay.toStringAsFixed(1)} hours per day'),
            Text('• Total: ${(dayCount * hoursPerDay).toStringAsFixed(1)} hours'),
            const SizedBox(height: 16),
            Text(
              'This will create $dayCount separate allocation records. Continue?',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create Allocations'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  Future<void> _showErrorsDialog(List<String> errors) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allocation Errors'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                errors[index],
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
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

  Future<void> _showValidationDialog(AllocationValidationResult validation, double requestedHours) async {
    if (validation.failureType == ValidationFailureType.budgetExceeded && 
        validation.maxAvailableHoursAsDecimal != null) {
      
      await showDialog(
        context: context,
        builder: (context) => BudgetValidationDialog(
          validation: validation,
          requestedHours: requestedHours,
          onUseMaxHours: (maxHours) {
            setState(() {
              _hoursController.text = maxHours.toStringAsFixed(1);
            });
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<int?> _getProjectRemainingBudget(int projectId) async {
    return await ref.read(allocationProvider.notifier).getProjectBudgetRemaining(projectId);
  }

  Future<Map<String, dynamic>> _getBudgetInfo() async {
    if (_selectedProject == null || _selectedEmployee == null) {
      return {'costPerHour': 0.0, 'remainingBudget': 0.0};
    }

    try {
      final employeeDataSource = ref.read(employeeLocalDataSourceProvider);
      final employee = await employeeDataSource.getEmployeeWithLevel(_selectedEmployee!.id!);
      final costPerHour = (employee['costPerHour'] as int) / 100.0;
      
      final remainingBudget = await _getProjectRemainingBudget(_selectedProject!.id!) ?? 0;
      
      return {
        'costPerHour': costPerHour,
        'remainingBudget': remainingBudget / 100.0,
      };
    } catch (e) {
      return {'costPerHour': 0.0, 'remainingBudget': 0.0};
    }
  }
}