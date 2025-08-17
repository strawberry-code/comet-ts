
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/repositories/user_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/create_user.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/get_user.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/domain/usecases/get_user_by_username.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/password_hasher.dart';

// Mocks
class MockLocalStorageService extends Mock implements LocalStorageService {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockUserRepository extends Mock implements UserRepository {}
class MockCreateUser extends Mock implements CreateUser {}
class MockGetUser extends Mock implements GetUser {}
class MockGetUserByUsername extends Mock implements GetUserByUsername {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockLocalStorageService mockLocalStorageService;
  late MockSecureStorageService mockSecureStorageService;
  late MockUserRepository mockUserRepository;
  late MockCreateUser mockCreateUser;
  late MockGetUser mockGetUser;
  late MockGetUserByUsername mockGetUserByUsername;

  setUpAll(() {
    registerFallbackValue(const GetUserByUsernameParams(username: ''));
    registerFallbackValue(const CreateUserParams(user: UserEntity(id: 0, username: '')));
  });

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    mockSecureStorageService = MockSecureStorageService();
    mockUserRepository = MockUserRepository();
    mockCreateUser = MockCreateUser();
    mockGetUser = MockGetUser();
    mockGetUserByUsername = MockGetUserByUsername();

    authRepository = AuthRepositoryImpl(
      localStorageService: mockLocalStorageService,
      secureStorageService: mockSecureStorageService,
      userRepository: mockUserRepository,
      createUserUseCase: mockCreateUser,
      getUserUseCase: mockGetUser,
      getUserByUsernameUseCase: mockGetUserByUsername,
    );
  });

  group('Auth - Register', () {
    const tUsername = 'testuser';
    const tPassword = 'password123';
    const tUser = UserEntity(id: 1, username: tUsername, passwordHash: 'hashed_password');

    test('should register a new user successfully', () async {
      // Arrange
      when(() => mockGetUserByUsername(any()))
          .thenAnswer((_) async => const Right(null)); // User does not exist
      when(() => mockCreateUser(any()))
          .thenAnswer((_) async => Right(tUser));
      when(() => mockLocalStorageService.setObject(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSecureStorageService.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});

      // Act
      final result = await authRepository.register(username: tUsername, password: tPassword);

      // Assert
      expect(result, Right(tUser));
    });

    test('should return ValidationFailure when user already exists', () async {
      // Arrange
      when(() => mockGetUserByUsername(any()))
          .thenAnswer((_) async => const Right(tUser)); // User already exists

      // Act
      final result = await authRepository.register(username: tUsername, password: tPassword);

      // Assert
      expect(result, const Left(ValidationFailure(message: 'User already exists')));
      verify(() => mockGetUserByUsername(const GetUserByUsernameParams(username: tUsername))).called(1);
      verifyNoMoreInteractions(mockCreateUser);
      verifyNoMoreInteractions(mockLocalStorageService);
      verifyNoMoreInteractions(mockSecureStorageService);
    });

    test('should return CacheFailure when user creation fails', () async {
      // Arrange
      when(() => mockGetUserByUsername(any()))
          .thenAnswer((_) async => const Right(null)); // User does not exist
      when(() => mockCreateUser(any()))
          .thenAnswer((_) async => const Left(CacheFailure())); // Creation fails

      // Act
      final result = await authRepository.register(username: tUsername, password: tPassword);

      // Assert
      expect(result, const Left(CacheFailure()));
      verify(() => mockGetUserByUsername(const GetUserByUsernameParams(username: tUsername))).called(1);
      verify(() => mockCreateUser(any(that: isA<CreateUserParams>()))).called(1);
      verifyNoMoreInteractions(mockLocalStorageService);
      verifyNoMoreInteractions(mockSecureStorageService);
    });
  });

  group('Auth - Login', () {
    const tUsername = 'testuser';
    const tPassword = 'password123';
    final tHashedPassword = PasswordHasher.hashPassword(tPassword); // Calculate hashed password
    final tUser = UserEntity(id: 1, username: tUsername, passwordHash: tHashedPassword);

    test('should log in a user successfully with correct credentials', () async {
      // Arrange
      when(() => mockGetUserByUsername(any()))
          .thenAnswer((_) async => Right(tUser)); // User found
      when(() => mockLocalStorageService.setObject(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSecureStorageService.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});

      // Act
      final result = await authRepository.login(username: tUsername, password: tPassword);

      // Assert
      expect(result, Right(tUser));
      verify(() => mockGetUserByUsername(const GetUserByUsernameParams(username: tUsername))).called(1);
      verify(() => mockLocalStorageService.setObject(AppConstants.userDataKey, tUsername)).called(1);
      verify(() => mockSecureStorageService.write(key: AppConstants.tokenKey, value: tUsername)).called(1);
    });

    test('should return AuthFailure when user not found', () async {
      // Arrange
      when(() => mockGetUserByUsername(any()))
          .thenAnswer((_) async => const Right(null)); // User not found

      // Act
      final result = await authRepository.login(username: tUsername, password: tPassword);

      // Assert
      expect(result, const Left(AuthFailure(message: 'User not found')));
      verify(() => mockGetUserByUsername(const GetUserByUsernameParams(username: tUsername))).called(1);
      verifyNoMoreInteractions(mockLocalStorageService);
      verifyNoMoreInteractions(mockSecureStorageService);
    });

    test('should return AuthFailure when password is incorrect', () async {
      // Arrange
      const tIncorrectPassword = 'wrong_password';
      when(() => mockGetUserByUsername(any()))
          .thenAnswer((_) async => Right(tUser)); // User found
      
      // Act
      final result = await authRepository.login(username: tUsername, password: tIncorrectPassword);

      // Assert
      expect(result, const Left(AuthFailure(message: 'Invalid credentials')));
      verify(() => mockGetUserByUsername(const GetUserByUsernameParams(username: tUsername))).called(1);
      verifyNoMoreInteractions(mockLocalStorageService);
      verifyNoMoreInteractions(mockSecureStorageService);
    });

    test('should return AuthFailure when user has no password hash (e.g., old user)', () async {
      // Arrange
      final tUserNoHash = UserEntity(id: 1, username: tUsername, passwordHash: null);
      when(() => mockGetUserByUsername(any()))
          .thenAnswer((_) async => Right(tUserNoHash)); // User found, no hash

      // Act
      final result = await authRepository.login(username: tUsername, password: tPassword);

      // Assert
      expect(result, const Left(AuthFailure(message: 'Invalid credentials')));
      verify(() => mockGetUserByUsername(const GetUserByUsernameParams(username: tUsername))).called(1);
      verifyNoMoreInteractions(mockLocalStorageService);
      verifyNoMoreInteractions(mockSecureStorageService);
    });

    test('should return CacheFailure when getting user fails', () async {
      // Arrange
      when(() => mockGetUserByUsername(any()))
          .thenAnswer((_) async => const Left(CacheFailure())); // Getting user fails

      // Act
      final result = await authRepository.login(username: tUsername, password: tPassword);

      // Assert
      expect(result, const Left(CacheFailure()));
      verify(() => mockGetUserByUsername(const GetUserByUsernameParams(username: tUsername))).called(1);
      verifyNoMoreInteractions(mockLocalStorageService);
      verifyNoMoreInteractions(mockSecureStorageService);
    });
  });

  group('Auth - Logout', () {
    test('should log out a user successfully', () async {
      // Arrange
      when(() => mockLocalStorageService.remove(any()))
          .thenAnswer((_) async => true);
      when(() => mockSecureStorageService.delete(key: any(named: 'key')))
          .thenAnswer((_) async => {});

      // Act
      final result = await authRepository.logout();

      // Assert
      expect(result, const Right(null));
      verify(() => mockLocalStorageService.remove(AppConstants.userDataKey)).called(1);
      verify(() => mockSecureStorageService.delete(key: AppConstants.tokenKey)).called(1);
    });

    test('should return ServerFailure when logout fails', () async {
      // Arrange
      when(() => mockLocalStorageService.remove(any()))
          .thenThrow(Exception('Logout failed')); // Simulate failure

      // Act
      final result = await authRepository.logout();

      // Assert
      expect(result, const Left(ServerFailure()));
      verify(() => mockLocalStorageService.remove(AppConstants.userDataKey)).called(1);
      verifyNoMoreInteractions(mockSecureStorageService);
    });
  });
}
