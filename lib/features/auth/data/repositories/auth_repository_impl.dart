import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/password_hasher.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/create_user.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/get_user.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/get_user_by_username.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/providers/user_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/shared_preferences_provider.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageService _localStorageService;
  final SecureStorageService _secureStorageService;
  final UserRepository _userRepository;
  final CreateUser _createUserUseCase;
  final GetUser _getUserUseCase;
  final GetUserByUsername _getUserByUsernameUseCase;
  
  AuthRepositoryImpl({
    required LocalStorageService localStorageService,
    required SecureStorageService secureStorageService,
    required UserRepository userRepository,
    required CreateUser createUserUseCase,
    required GetUser getUserUseCase,
    required GetUserByUsername getUserByUsernameUseCase,
  }) : _localStorageService = localStorageService,
       _secureStorageService = secureStorageService,
       _userRepository = userRepository,
       _createUserUseCase = createUserUseCase,
       _getUserUseCase = getUserUseCase,
       _getUserByUsernameUseCase = getUserByUsernameUseCase;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username, 
    required String password,
  }) async {
    try {
      final userResult = await _getUserByUsernameUseCase(GetUserByUsernameParams(username: username));
      
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          if (user == null) {
            print('Login failed: User not found after retrieval.');
            return const Left(AuthFailure(message: 'User not found'));
          }
          print('Login: User retrieved: ${user.username} with passwordHash: ${user.passwordHash}');
          if (user.passwordHash == null || !PasswordHasher.verifyPassword(password, user.passwordHash!)) {
            print('Login failed: Invalid credentials. Stored hash: ${user.passwordHash}');
            return const Left(AuthFailure(message: 'Invalid credentials'));
          }
          
          // Save user data locally
          await _localStorageService.setObject(AppConstants.userDataKey, user.username);
          
          // Save auth token securely (using username as token for now)
          await _secureStorageService.write(
            key: AppConstants.tokenKey, 
            value: user.username,
          );
          
          return Right(user);
        },
      );
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      // Log the error for debugging
      print('Unexpected error during login: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String password,
  }) async {
    try {
      // Check if user already exists (assuming username is unique)
      final existingUserResult = await _getUserByUsernameUseCase(GetUserByUsernameParams(username: username));
      if (existingUserResult.isRight() && existingUserResult.getOrElse(() => null) != null) {
        return const Left(ValidationFailure(message: 'User already exists'));
      }

      final hashedPassword = PasswordHasher.hashPassword(password);
      print('Registering user: $username with hashed password: $hashedPassword');
      final newUser = UserEntity(
        id: 0, // Let the database auto-increment the ID
        username: username,
        passwordHash: hashedPassword,
      );
      
      final createdUserResult = await _createUserUseCase(CreateUserParams(user: newUser));
      
      return createdUserResult.fold(
        (failure) => Left(failure),
        (user) async {
          // Save user data locally
          await _localStorageService.setObject(AppConstants.userDataKey, user.username);
          
          // Save auth token securely (using username as token for now)
          await _secureStorageService.write(
            key: AppConstants.tokenKey, 
            value: user.username,
          );
          
          return Right(user);
        },
      );
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      // Log the error for debugging
      print('Unexpected error during registration: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Remove user data from local storage
      await _localStorageService.remove(AppConstants.userDataKey);
      
      // Remove auth token from secure storage
      await _secureStorageService.delete(key: AppConstants.tokenKey);
      
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}

// Dependencies
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.create();
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final createUserUseCase = ref.watch(createUserProvider);
  final getUserUseCase = ref.watch(getUserProvider);
  final getUserByUsernameUseCase = ref.watch(getUserByUsernameProvider);

  return AuthRepositoryImpl(
    localStorageService: localStorageService,
    secureStorageService: secureStorageService,
    userRepository: userRepository,
    createUserUseCase: createUserUseCase,
    getUserUseCase: getUserUseCase,
    getUserByUsernameUseCase: getUserByUsernameUseCase,
  );
});
