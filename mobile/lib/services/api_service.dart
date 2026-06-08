import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/nasheed.dart';
import '../models/user.dart';
import '../models/quran_surah.dart';

const _baseUrl = 'http://10.0.2.2:3000/api'; // localhost для Android эмулятора
// const _baseUrl = 'http://localhost:3000/api'; // iOS симулятор

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  final _storage = const FlutterSecureStorage();
  late final Dio _dio;

  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() => _storage.read(key: 'auth_token');

  // Auth
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final res = await _dio.post('/auth/google', data: {'idToken': idToken});
    return res.data;
  }

  Future<User> selectRole(String role) async {
    final res = await _dio.post('/auth/role', data: {'role': role});
    return User.fromJson(res.data['user']);
  }

  Future<User> getMe() async {
    final res = await _dio.get('/auth/me');
    return User.fromJson(res.data['user']);
  }

  // Nasheeds
  Future<List<Nasheed>> getNasheeds({int page = 1, String sort = 'newest'}) async {
    final res = await _dio.get('/nasheeds', queryParameters: {'page': page, 'sort': sort});
    return (res.data['nasheeds'] as List).map((e) => Nasheed.fromJson(e)).toList();
  }

  Future<List<Nasheed>> searchNasheeds(String query) async {
    final res = await _dio.get('/nasheeds/search', queryParameters: {'q': query});
    return (res.data['nasheeds'] as List).map((e) => Nasheed.fromJson(e)).toList();
  }

  Future<List<Nasheed>> getArtistNasheeds(String artistId) async {
    final res = await _dio.get('/artists/$artistId/nasheeds');
    return (res.data['nasheeds'] as List).map((e) => Nasheed.fromJson(e)).toList();
  }

  Future<void> likeNasheed(String id) => _dio.post('/nasheeds/$id/like');
  Future<void> unlikeNasheed(String id) => _dio.delete('/nasheeds/$id/like');
  Future<void> recordPlay(String id, {int duration = 0}) =>
      _dio.post('/nasheeds/$id/play', data: {'duration': duration});

  Future<List<Nasheed>> getLikedNasheeds() async {
    final res = await _dio.get('/users/me/liked');
    return (res.data['nasheeds'] as List).map((e) => Nasheed.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final res = await _dio.get('/users/me/history');
    return List<Map<String, dynamic>>.from(res.data['history']);
  }

  // Upload nasheed
  Future<Nasheed> uploadNasheed({
    required String title,
    String? description,
    required String audioPath,
    String? coverPath,
    required int duration,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'duration': duration,
      'audio': await MultipartFile.fromFile(audioPath),
      if (coverPath != null) 'cover': await MultipartFile.fromFile(coverPath),
    });
    final res = await _dio.post('/nasheeds', data: formData);
    return Nasheed.fromJson(res.data['nasheed']);
  }

  // Artist verification
  Future<void> submitVerification({String? bio, String? documentPath}) async {
    final formData = FormData.fromMap({
      if (bio != null) 'bio': bio,
      if (documentPath != null) 'document': await MultipartFile.fromFile(documentPath),
    });
    await _dio.post('/artists/verification', data: formData);
  }

  // Quran
  Future<List<QuranSurah>> getSurahs() async {
    final res = await _dio.get('/quran');
    return (res.data['surahs'] as List).map((e) => QuranSurah.fromJson(e)).toList();
  }

  // Stats
  Future<Map<String, dynamic>> getArtistStats() async {
    final res = await _dio.get('/stats/artist');
    return res.data;
  }

  // User profile
  Future<User> getUserProfile(String id) async {
    final res = await _dio.get('/users/$id');
    return User.fromJson(res.data['user']);
  }

  Future<void> followArtist(String id) => _dio.post('/users/$id/follow');
  Future<void> unfollowArtist(String id) => _dio.delete('/users/$id/follow');
}
