import '../entities/sign_entry.dart';
import '../entities/word_detail.dart';

abstract interface class DictionaryRepository {
  Future<List<SignEntry>> fetchAll();
  Future<WordDetail> fetchById(int id);
}
