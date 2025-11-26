// ----user firestore management
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection("users");
  final _otp = FirebaseFirestore.instance.collection("otp_codes");

  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    await _users.doc(uid).set({
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "twoFactor": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<bool> getTwoFactor(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return false;
    final data = snap.data() as Map<String, dynamic>;
    return data["twoFactor"] == true;
  }

  Future<void> setTwoFactor(String uid, bool enabled) async {
    await _users.doc(uid).update({"twoFactor": enabled});
  }

  Future<void> saveOtp(String uid, String code) async {
    await _otp.doc(uid).set({
      "code": code,
      "expires": DateTime.now().millisecondsSinceEpoch + 5 * 60 * 1000,
    });
  }

  Future<bool> verifyOtp(String uid, String code) async {
    final snap = await _otp.doc(uid).get();
    if (!snap.exists) return false;

    final data = snap.data() as Map<String, dynamic>;
    final savedCode = data["code"];
    final expires = data["expires"];

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > expires) return false;

    return savedCode == code;
  }
}
