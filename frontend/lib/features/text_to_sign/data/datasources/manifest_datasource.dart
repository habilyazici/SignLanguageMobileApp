import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';

final manifestDatasourceProvider = Provider((ref) => const ManifestDatasource());

/// Backend'den kelime → videoUrl haritasını çeker.
/// Uygulama açılışında bir kez yüklenir, bellekte tutulur.
class ManifestDatasource {
  const ManifestDatasource();

  Future<Map<String, String>> fetchManifest() async {
    final res = await http
        .get(
          Uri.parse('$kApiBaseUrl/api/words/manifest'),
          headers: kNgrokHeaders,
        )
        .timeout(kDataTimeout);

    if (res.statusCode != 200) {
      throw Exception('Manifest yüklenemedi: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final rawWords = body['words'];
    if (rawWords is! Map) throw Exception('Beklenmeyen manifest formatı.');
    return rawWords.map((k, v) => MapEntry(k as String, v as String));
  }
}
