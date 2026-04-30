/// Sözlük detay sayfasında gösterilen kelime verisi.
class WordDetail {
  final int id;
  final String word;
  final String letter;
  final String? meaningEn;
  final String videoUrl;
  final List<String> allVideos;

  const WordDetail({
    required this.id,
    required this.word,
    required this.letter,
    required this.meaningEn,
    required this.videoUrl,
    required this.allVideos,
  });
}
