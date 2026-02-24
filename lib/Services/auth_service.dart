import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// =========================
  /// SAVE FCM TOKEN
  /// =========================
  Future<void> _saveFCMToken(String uid) async {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// 🔥 Request permission (Android 13+ / iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print("Permission status: ${settings.authorizationStatus}");

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("❌ Notification permission denied");
    return;
  }

   String? token = await messaging.getToken();

  print("🔥 FCM TOKEN = $token");

  if (token != null) {
    await _firestore.collection("users").doc(uid).update({
      'fcmToken': token,
    });
  }
}
  /// =========================
  /// SIGNUP
  /// =========================
  Future<String?> signup({
    required String email,
    required String password,
    required String name,
  }) async {

    try {

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection("users").doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

       await _saveFCMToken(uid);

      return null;

    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// =========================
  /// LOGIN
  /// =========================
  Future<String?> login({
    required String email,
    required String password,
  }) async {

    try {

      UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// 🔥 Save FCM Token after login
      await _saveFCMToken(credential.user!.uid);

      return null;

    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Future<void> logout() async {
    await _auth.signOut();
  }
}