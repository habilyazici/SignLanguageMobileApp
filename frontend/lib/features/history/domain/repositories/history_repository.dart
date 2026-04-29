import '../entities/history_item.dart';

abstract class HistoryRepository {
  Future<List<HistoryItem>> fetchHistory({int offset = 0, int limit = 50});
  Future<HistoryItem> addHistory(String text);
  Future<void> deleteHistory(String id);
  Future<void> clearAllHistory();
}
