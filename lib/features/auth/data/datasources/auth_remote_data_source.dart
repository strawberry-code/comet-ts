import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  /// Login a user with username and password
  Future<UserEntity> login({required String username, required String password});
  
  /// Register a new user
  Future<UserEntity> register({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  
  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserEntity> login({required String username, required String password}) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }
      
      // In a real app, you would make an API call here
      // For this template, we'll simulate a successful login
      
      // Simulating a backend call with delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock user for demonstration
      return UserEntity(
        id: 1, // Mock ID
        username: username,
        passwordHash: 'mock_hashed_password',
        biometricsEnabled: false,
      );
      
      // In real implementation:
      // final response = await _apiClient.post('/auth/login', data: {
      //   'username': username,
      //   'password': password,
      // });
      // return UserEntity.fromJson(response['user']);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<UserEntity> register({
    required String username,
    required String password,
  }) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }
      
      // In a real app, you would make an API call here
      // For this template, we'll simulate a successful registration
      
      // Simulating a backend call with delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock user for demonstration
      return UserEntity(
        id: DateTime.now().millisecondsSinceEpoch, // Mock ID
        username: username,
        passwordHash: 'mock_hashed_password',
        biometricsEnabled: false,
      );
      
      // In real implementation:
      // final response = await _apiClient.post('/auth/register', data: {
      //   'username': username,
      //   'password': password,
      // });
      // return UserEntity.fromJson(response['user']);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
  
  // Helper method to handle exceptions
  Exception _handleException(Exception e) {
    if (e is NetworkException || 
        e is ServerException || 
        e is UnauthorizedException || 
        e is BadRequestException) {
      return e;
    }
    return ServerException(message: e.toString());
  }
}

// Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

// ApiClient provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
