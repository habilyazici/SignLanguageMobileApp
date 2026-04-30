import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/sign_entry.dart';
import '../../domain/entities/word_detail.dart';

final dictionaryDatasourceProvider = Provider((ref) => DictionaryApiDatasource(ref));

class DictionaryApiDatasource {
  final Ref _ref;
  const DictionaryApiDatasource(this._ref);

  Future<List<SignEntry>> fetchAll() async {
    final all = <SignEntry>[];
    int page = 1;
    const limit = 200;

    while (true) {
      final res = await _ref.apiGet('/api/words?page=$page&limit=$limit');

      if (res.statusCode != 200) {
        throw Exception('Kelimeler yüklenemedi (HTTP ${res.statusCode}).');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final rawData = body['data'];
      if (rawData is! List) throw Exception('Beklenmeyen API yanıtı: data alanı eksik.');
      final data = rawData.cast<Map<String, dynamic>>();

      for (final item in data) {
        all.add(SignEntry(
          id: item['id'] as int,
          label: item['word'] as String,
          category: item['letter'] as String,
          description: item['meaningEn'] as String?,
          videoUrl: item['videoUrl'] as String?,
        ));
      }

      final pages = (body['pages'] as num?)?.toInt() ?? 1;
      if (page >= pages) break;
      page++;
    }

    return all;
  }

  Future<WordDetail> fetchById(int id) async {
    final res = await _ref.apiGet('/api/words/$id');
    if (res.statusCode != 200) {
      throw Exception('Kelime yüklenemedi (HTTP ${res.statusCode}).');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return WordDetail(
      id: j['id'] as int,
      word: j['word'] as String,
      letter: j['letter'] as String,
      meaningEn: j['meaningEn'] as String?,
      videoUrl: j['videoUrl'] as String,
      allVideos: (j['allVideos'] as List?)?.cast<String>() ?? [],
    );
  }
}
