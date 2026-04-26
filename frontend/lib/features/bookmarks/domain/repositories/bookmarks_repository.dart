abstract interface class BookmarksRepository {
  Future<Set<int>> fetchBookmarks();
  Future<void> addBookmark(int wordId);
  Future<void> deleteBookmark(int wordId);
}
