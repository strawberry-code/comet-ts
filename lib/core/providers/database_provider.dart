import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/app_database.dart';

// Highly experimental: Direct initialization of AppDatabase
late final AppDatabase appDatabaseInstance = AppDatabase();

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return appDatabaseInstance;
});