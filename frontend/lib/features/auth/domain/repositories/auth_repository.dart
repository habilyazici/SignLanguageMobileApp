import '../entities/auth_state.dart';

abstract interface class AuthRepository {
  /// E-posta ve şifre ile giriş yapar.
  Future<AuthState> signIn({
    required String email,
    required String password,
  });

  /// Yeni hesap oluşturur.
  Future<AuthState> register({
    required String name,
    required String email,
    required String password,
  });

  /// Güvenli depolamadan mevcut oturumu yükler.
  Future<AuthState> restoreSession();

  /// Token ve kullanıcı bilgilerini güvenli depolamadan siler.
  Future<void> clearSession();

  /// Adı ve/veya şifreyi günceller.
  Future<({bool success, String? error, String? newName})> updateProfile({
    String? name,
    String? currentPassword,
    String? newPassword,
  });

  /// Şifre sıfırlama kodu e-posta ile gönderir (hata olsa bile sessiz geçer).
  Future<void> forgotPassword({required String email});

  /// OTP kodu ve yeni şifre ile şifreyi sıfırlar.
  Future<({bool success, String? error})> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
