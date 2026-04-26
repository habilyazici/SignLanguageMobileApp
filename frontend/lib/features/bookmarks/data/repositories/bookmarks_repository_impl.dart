import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../datasources/bookmarks_api_datasource.dart';

export '../../domain/repositories/bookmarks_repository.dart';

final bookmarksRepositoryProvider = Provider<BookmarksRepository>((ref) {
  final datasource = ref.watch(bookmarksDatasourceProvider);
  return BookmarksRepositoryImpl(datasource);
});

class BookmarksRepositoryImpl implements BookmarksRepository {
  final BookmarksApiDatasource _datasource;
  const BookmarksRepositoryImpl(this._datasource);

  @override
  Future<Set<int>> fetchBookmarks() => _datasource.fetchBookmarks();

  @override
  Future<void> addBookmark(int wordId) => _datasource.addBookmark(wordId);

  @override
  Future<void> deleteBookmark(int wordId) => _datasource.deleteBookmark(wordId);
}
