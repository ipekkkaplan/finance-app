// data/repositories/algo_trade_repository.dart
import '../../services/algo_trade_service.dart';

/// Algo-trade akışı için repository katmanı.
///
/// [AlgoTradeService] hem Supabase hem Firebase ile konuşur; UI bu detaylara
/// bağlanmak yerine bu soyutlamaya bağlanır. Metod imzaları servisle birebir
/// korunmuştur (çevre kodla uyum + güvenli geçiş).
class AlgoTradeRepository {
  AlgoTradeRepository(this._service);

  final AlgoTradeService _service;

  Future<String> riskProfiliGetir() => _service.riskProfiliGetir();

  Future<Map<String, dynamic>?> aktifOturum() => _service.aktifOturum();

  Future<void> oturumBaslat({
    required double sermaye,
    required String riskProfili,
    required String mod,
    List<String> izinliSektorler = const [],
    List<String> beyazListe = const [],
    List<String> karaListe = const [],
  }) =>
      _service.oturumBaslat(
        sermaye: sermaye,
        riskProfili: riskProfili,
        mod: mod,
        izinliSektorler: izinliSektorler,
        beyazListe: beyazListe,
        karaListe: karaListe,
      );

  Future<void> oturumDurdur(int oturumId, String cikisModu) =>
      _service.oturumDurdur(oturumId, cikisModu);

  Future<void> oturumTamamenDurdur(int oturumId, String cikisModu) =>
      _service.oturumTamamenDurdur(oturumId, cikisModu);

  Future<List<Map<String, dynamic>>> acikPozisyonlar(int oturumId) =>
      _service.acikPozisyonlar(oturumId);

  Future<List<Map<String, dynamic>>> kapananIslemler(int oturumId) =>
      _service.kapananIslemler(oturumId);

  Future<List<Map<String, dynamic>>> equityEgrisi(int oturumId) =>
      _service.equityEgrisi(oturumId);

  Future<Map<String, dynamic>> sistemDurumu() => _service.sistemDurumu();

  Future<Map<String, double>> guncelFiyatlar(List<String> semboller) =>
      _service.guncelFiyatlar(semboller);

  Future<void> pozisyonGuncelle(int tradeId, double stopPx, double tpPx) =>
      _service.pozisyonGuncelle(tradeId, stopPx, tpPx);

  Future<void> pozisyonAnindaKapat(
          int tradeId, double entryPx, double qty, double guncelFiyat) =>
      _service.pozisyonAnindaKapat(tradeId, entryPx, qty, guncelFiyat);
}
