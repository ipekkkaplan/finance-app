/// Al-Sat sinyal türleri.
enum SignalType {
  strongBuy, // Güçlü Al
  buy,       // Al
  hold,      // Bekle
  sell,      // Sat
}

extension SignalTypeX on SignalType {
  String get label {
    switch (this) {
      case SignalType.strongBuy:
        return 'GÜÇLÜ AL';
      case SignalType.buy:
        return 'AL';
      case SignalType.hold:
        return 'BEKLE';
      case SignalType.sell:
        return 'SAT';
    }
  }

  String get shortLabel {
    switch (this) {
      case SignalType.strongBuy:
        return 'G.AL';
      case SignalType.buy:
        return 'AL';
      case SignalType.hold:
        return 'BEKLE';
      case SignalType.sell:
        return 'SAT';
    }
  }
}

/// Bir hisse için üretilmiş al-sat sinyali.
class SignalModel {
  final String hisseKodu;
  final String sirketIsmi;
  final String sektor;
  final SignalType type;
  final double confidence; // 0.0 - 1.0
  final String reason;     // İnsan-okuyabilir sebep

  const SignalModel({
    required this.hisseKodu,
    required this.sirketIsmi,
    required this.sektor,
    required this.type,
    required this.confidence,
    required this.reason,
  });
}
