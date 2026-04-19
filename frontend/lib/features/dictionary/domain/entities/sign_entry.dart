/// Sözlükteki tek bir işaret kelimesini temsil eden domain entity.
class SignEntry {
  final int id;
  final String label; // Türkçe kelime
  final String category; // Örn: Temel, Mutfak, Okul
  final String? description; // Kelimenin kullanımı veya anlamı
  final String? videoUrl; // İşaretin videosu (URL veya assets yolu)

  const SignEntry({
    required this.id,
    required this.label,
    this.category = 'Genel',
    this.description,
    this.videoUrl,
  });

  SignEntry copyWith({
    int? id,
    String? label,
    String? category,
    String? description,
    String? videoUrl,
  }) {
    return SignEntry(
      id: id ?? this.id,
      label: label ?? this.label,
      category: category ?? this.category,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
