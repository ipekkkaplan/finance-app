import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Hisse altı yorumları için Firestore servis sınıfı.
///
/// Koleksiyon yapısı:
///   stock_comments/{hisseKodu}/comments/{autoId}
///     - uid: String          (yazarın FirebaseAuth uid'i)
///     - displayName: String  (yazarın görünen adı)
///     - text: String         (yorum metni, max 500 karakter)
///     - createdAt: Timestamp (sunucu zaman damgası)
class CommentsService {
  static const int maxLength = 500;
  static const int pageLimit = 100;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String hisseKodu) =>
      _db.collection('stock_comments').doc(hisseKodu).collection('comments');

  /// Belirli bir hissenin yorumlarını canlı olarak dinler (en yeniler üstte).
  Stream<QuerySnapshot<Map<String, dynamic>>> watch(String hisseKodu) {
    return _col(hisseKodu)
        .orderBy('createdAt', descending: true)
        .limit(pageLimit)
        .snapshots();
  }

  /// Yeni bir yorum ekler. Giriş yapılmamışsa veya metin geçersizse hata atar.
  Future<void> add(String hisseKodu, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('not_logged_in');
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('empty_text');
    }
    if (trimmed.length > maxLength) {
      throw ArgumentError('text_too_long');
    }

    await _col(hisseKodu).add({
      'uid': user.uid,
      'displayName': (user.displayName ?? '').trim().isEmpty
          ? 'Anonim'
          : user.displayName,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Yorumu siler. Firestore kuralları sadece sahibinin silmesine izin verir.
  Future<void> delete(String hisseKodu, String commentId) async {
    await _col(hisseKodu).doc(commentId).delete();
  }
}
