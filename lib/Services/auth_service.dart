import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
final FirebaseAuth  _auth =FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Future<String?> signup({ required String email, required String password, required String name  ,}) async{
    try{
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid =userCredential.user!.uid;
      await _firestore.collection("users").doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }


    }
      /// LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  }


