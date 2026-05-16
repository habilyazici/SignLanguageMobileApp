import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

/// Kullanıcının profil fotoğrafı URL'ini AuthState üzerinden sağlar.
/// Backend'e yüklenen fotoğraf URL'i AuthState.avatarUrl'de saklanır;
/// oturum süresi dolana veya çıkış yapılana kadar SecureStorage'dan geri yüklenir.
final avatarProvider = Provider<String?>((ref) {
  return ref.watch(authProvider.select((s) => s.avatarUrl));
});
