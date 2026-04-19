import '../../../../../core/domain/repositories/label_repository.dart';
import '../../domain/entities/sign_entry.dart';

/// LabelRepository üzerinden zaten yüklü olan etiketleri okur.
class DictionaryLocalDatasource {
  const DictionaryLocalDatasource(this._labels);

  final LabelRepository _labels;

  List<SignEntry> readAll() => _labels.getAllEntries().map((e) {
    final (id, label) = e;

    // Şimdilik demo için ID'ye göre kategorize et
    final String category = switch (id % 5) {
      0 => 'Temel',
      1 => 'Günlük Yaşam',
      2 => 'Mutfak & Yemek',
      3 => 'Zaman & Hava',
      _ => 'Okul & Eğitim',
    };

    return SignEntry(
      id: id,
      label: label,
      category: category,
      description: '$label kelimesinin Türk İşaret Dili (TİD) karşılığı.',
      // Gelecekte gerçek asset'ler eklendiğinde kullanılacak path
      videoUrl: 'assets/videos/sign_$id.mp4',
    );
  }).toList();
}
