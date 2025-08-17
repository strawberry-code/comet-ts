import 'package:equatable/equatable.dart';

class AllocationValidationResult extends Equatable {
  final bool isValid;
  final String? errorMessage;
  final int? maxAvailableHours; // in minutes
  final int? requiredBudget; // in cents
  final int? availableBudget; // in cents
  final ValidationFailureType? failureType;

  const AllocationValidationResult({
    required this.isValid,
    this.errorMessage,
    this.maxAvailableHours,
    this.requiredBudget,
    this.availableBudget,
    this.failureType,
  });

  const AllocationValidationResult.valid()
      : isValid = true,
        errorMessage = null,
        maxAvailableHours = null,
        requiredBudget = null,
        availableBudget = null,
        failureType = null;

  const AllocationValidationResult.invalid({
    required String errorMessage,
    int? maxAvailableHours,
    int? requiredBudget,
    int? availableBudget,
    ValidationFailureType? failureType,
  })  : isValid = false,
        errorMessage = errorMessage,
        maxAvailableHours = maxAvailableHours,
        requiredBudget = requiredBudget,
        availableBudget = availableBudget,
        failureType = failureType;

  double? get maxAvailableHoursAsDecimal =>
      maxAvailableHours != null ? maxAvailableHours! / 60.0 : null;

  double? get requiredBudgetAsEuros =>
      requiredBudget != null ? requiredBudget! / 100.0 : null;

  double? get availableBudgetAsEuros =>
      availableBudget != null ? availableBudget! / 100.0 : null;

  @override
  List<Object?> get props => [
        isValid,
        errorMessage,
        maxAvailableHours,
        requiredBudget,
        availableBudget,
        failureType,
      ];
}

enum ValidationFailureType {
  dailyLimit,
  budgetExceeded,
  invalidInput,
  projectNotFound,
  employeeNotFound,
}