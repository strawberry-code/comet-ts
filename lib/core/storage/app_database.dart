
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tables

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get pinHash => text().nullable()();
  BoolColumn get biometricsEnabled => boolean().withDefault(const Constant(false))();
}

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get budget => integer()(); // Renamed from budgetHours
  IntColumn get startDate => integer()(); // New field for Unix timestamp
  IntColumn get endDate => integer()(); // New field for Unix timestamp
}

class Levels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Employees extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get levelId => integer().references(Levels, #id)();
}

class Allocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  IntColumn get employeeId => integer().references(Employees, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get hours => integer()();
}

@DriftDatabase(tables: [Users, Projects, Levels, Employees, Allocations])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
