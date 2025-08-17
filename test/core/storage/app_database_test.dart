
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('database can be opened', () {
    expect(database, isA<AppDatabase>());
  });

  group('CRUD operations', () {
    test('can insert and read a user', () async {
      final user = UsersCompanion.insert(
        username: 'testuser',
      );
      final id = await database.into(database.users).insert(user);
      final retrievedUser = await (database.select(database.users)..where((u) => u.id.equals(id))).getSingle();
      expect(retrievedUser.username, 'testuser');
    });

    test('can insert and read a project', () async {
      final project = ProjectsCompanion.insert(
        name: 'Test Project',
        budgetHours: 100,
      );
      final id = await database.into(database.projects).insert(project);
      final retrievedProject = await (database.select(database.projects)..where((p) => p.id.equals(id))).getSingle();
      expect(retrievedProject.name, 'Test Project');
      expect(retrievedProject.budgetHours, 100);
    });

    test('can insert and read a level', () async {
      final level = LevelsCompanion.insert(
        name: 'Senior',
      );
      final id = await database.into(database.levels).insert(level);
      final retrievedLevel = await (database.select(database.levels)..where((l) => l.id.equals(id))).getSingle();
      expect(retrievedLevel.name, 'Senior');
    });

    test('can insert and read an employee with a level', () async {
      // First, insert a level
      final level = LevelsCompanion.insert(
        name: 'Junior',
      );
      final levelId = await database.into(database.levels).insert(level);

      // Then, insert an employee with that level
      final employee = EmployeesCompanion.insert(
        name: 'John Doe',
        levelId: levelId,
      );
      final employeeId = await database.into(database.employees).insert(employee);

      final retrievedEmployee = await (database.select(database.employees)..where((e) => e.id.equals(employeeId))).getSingle();
      expect(retrievedEmployee.name, 'John Doe');
      expect(retrievedEmployee.levelId, levelId);
    });

    test('can insert and read an allocation', () async {
      // First, insert a project and an employee
      final project = ProjectsCompanion.insert(name: 'Allocation Project', budgetHours: 50);
      final projectId = await database.into(database.projects).insert(project);

      final level = LevelsCompanion.insert(name: 'Mid');
      final levelId = await database.into(database.levels).insert(level);

      final employee = EmployeesCompanion.insert(name: 'Jane Smith', levelId: levelId);
      final employeeId = await database.into(database.employees).insert(employee);

      // Then, insert an allocation
      final allocation = AllocationsCompanion.insert(
        projectId: projectId,
        employeeId: employeeId,
        date: DateTime.now(),
        hours: 8,
      );
      final allocationId = await database.into(database.allocations).insert(allocation);

      final retrievedAllocation = await (database.select(database.allocations)..where((a) => a.id.equals(allocationId))).getSingle();
      expect(retrievedAllocation.projectId, projectId);
      expect(retrievedAllocation.employeeId, employeeId);
      expect(retrievedAllocation.hours, 8);
    });
  });
}
