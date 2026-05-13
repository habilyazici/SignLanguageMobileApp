import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

export '../../domain/entities/auth_state.dart' show AuthStatus, AuthState;

final _authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

// ─────────────────────────────────────────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.keepAlive();
    _restoreSession();
    return const AuthState(status: AuthStatus.loading);
  }

  Future<void> _restoreSession() async {
    try {
      final repo = ref.read(_authRepositoryProvider);
      // 5 saniye içinde tamamlanmazsa guest olarak devam et
      final restored = await repo.restoreSession().timeout(
        const Duration(seconds: 5),
        onTimeout: () => const AuthState(),
      );
      if (state.status == AuthStatus.loading) {
        state = restored;
      }
    } catch (_) {
      if (state.status == AuthStatus.loading) {
        state = const AuthState();
      }
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await ref
        .read(_authRepositoryProvider)
        .signIn(email: email, password: password);
    state = result;
    return result.isAuthenticated;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await ref
        .read(_authRepositoryProvider)
        .register(name: name, email: email, password: password);
    state = result;
    return result.isAuthenticated;
  }

  Future<void> signOut() async {
    await ref.read(_authRepositoryProvider).clearSession();
    state = const AuthState();
  }

  Future<String?> deleteAccount() async {
    final result = await ref.read(_authRepositoryProvider).deleteAccount();
    if (result.success) {
      state = const AuthState();
    } else {
      // Repository 401 alınca clearSession() çağırır (storage temizlenir) ama
      // Riverpod state'i güncellemez. restoreSession ile senkronize et.
      final restored = await ref.read(_authRepositoryProvider).restoreSession();
      if (!restored.isAuthenticated) state = const AuthState();
    }
    return result.error;
  }

  Future<String?> updateProfile({
    String? name,
    String? currentPassword,
    String? newPassword,
  }) async {
    final result = await ref.read(_authRepositoryProvider).updateProfile(
      name: name,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (result.success && result.newName != null) {
      state = state.copyWith(displayName: result.newName);
    } else if (!result.success) {
      // Repository 401 alınca clearSession() çağırır (storage temizlenir) ama
      // Riverpod state'i güncellemez. restoreSession ile senkronize et.
      final restored = await ref.read(_authRepositoryProvider).restoreSession();
      if (!restored.isAuthenticated) state = const AuthState();
    }
    return result.error;
  }

  Future<void> forgotPassword({required String email}) =>
      ref.read(_authRepositoryProvider).forgotPassword(email: email);

  Future<({bool success, String? error})> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      ref.read(_authRepositoryProvider).resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
}
