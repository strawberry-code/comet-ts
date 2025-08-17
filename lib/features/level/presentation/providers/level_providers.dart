import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/database_provider.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/data/datasources/level_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/data/repositories/level_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/entities/level_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/repositories/level_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/create_level.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/delete_level.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/get_all_levels.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/get_level.dart';
import 'package:flutter_riverpod_clean_architecture/features/level/domain/usecases/update_level.dart';

// Data Source Provider
final levelLocalDataSourceProvider = Provider<LevelLocalDataSource>((ref) {
  final appDatabase = ref.watch(appDatabaseProvider);
  return LevelLocalDataSourceImpl(appDatabase: appDatabase);
});

// Repository Provider
final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  final localDataSource = ref.watch(levelLocalDataSourceProvider);
  return LevelRepositoryImpl(localDataSource: localDataSource);
});

// Use Case Providers
final createLevelUseCaseProvider = Provider<CreateLevel>((ref) {
  final repository = ref.watch(levelRepositoryProvider);
  return CreateLevel(repository);
});

final getLevelUseCaseProvider = Provider<GetLevel>((ref) {
  final repository = ref.watch(levelRepositoryProvider);
  return GetLevel(repository);
});

final getAllLevelsUseCaseProvider = Provider<GetAllLevels>((ref) {
  final repository = ref.watch(levelRepositoryProvider);
  return GetAllLevels(repository);
});

final updateLevelUseCaseProvider = Provider<UpdateLevel>((ref) {
  final repository = ref.watch(levelRepositoryProvider);
  return UpdateLevel(repository);
});

final deleteLevelUseCaseProvider = Provider<DeleteLevel>((ref) {
  final repository = ref.watch(levelRepositoryProvider);
  return DeleteLevel(repository);
});

// Levels List Provider
final levelsListProvider = FutureProvider.autoDispose<List<LevelEntity>>((ref) async {
  final getAllLevels = ref.watch(getAllLevelsUseCaseProvider);
  return (await getAllLevels(NoParams())).fold(
    (failure) => throw failure,
    (levels) => levels,
  );
});
