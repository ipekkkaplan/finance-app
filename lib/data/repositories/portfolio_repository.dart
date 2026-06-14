// data/repositories/portfolio_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı portföyü için repository katmanı.
///
/// Önceden Firestore çağrıları doğrudan `PortfolioScreen` içine gömülüydü
/// (UI'da iş mantığı). Artık bu katman üzerinden yapılır; ekran sadece
/// arayüzle ilgilenir.
class PortfolioRepository {
  PortfolioRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String _collection = 'user_match';

  /// Kullanıcının portföy belgesini canlı dinler.
  /// (uid null güvenli — mevcut davranış korunmuştur.)
  Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String? uid) =>
      _db.collection(_collection).doc(uid).snapshots();

  /// Toplam bakiyeyi günceller (varsa birleştirir).
  Future<void> updateTotalBalance(String? uid, double value) =>
      _db.collection(_collection).doc(uid).set(
        {'totalBalance': value},
        SetOptions(merge: true),
      );
}
