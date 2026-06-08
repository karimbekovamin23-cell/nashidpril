import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final token = await ApiService().getToken();
    if (token == null) return null;
    try {
      return await ApiService().getMe();
    } catch (_) {
      await ApiService().clearToken();
      return null;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = const AsyncData(null);
        return false;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No ID token');

      final data = await ApiService().googleLogin(idToken);
      await ApiService().saveToken(data['token']);
      final user = User.fromJson(data['user']);

      state = AsyncData(user);
      return data['isNew'] == true; // вернёт true если нужен выбор роли
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> selectRole(String role) async {
    final user = await ApiService().selectRole(role);
    state = AsyncData(user);
  }

  Future<void> refresh() async {
    final user = await ApiService().getMe();
    state = AsyncData(user);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await ApiService().clearToken();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() => AuthNotifier());
