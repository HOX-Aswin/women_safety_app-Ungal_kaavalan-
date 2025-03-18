import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<User?> signIn(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      DocumentSnapshot doc = await usersCollection.doc(user.uid).get();

      // ✅ If user data doesn't exist, add default values
      if (!doc.exists) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: "New User",
          phone: "",
          gender: "",
          age: "",
          address: "",
          aadhar: "",
        );
        await usersCollection.doc(user.uid).set(newUser.toMap());
      }
    }

    return user;
  }

  Future<User?> signUp(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      UserModel newUser = UserModel(
        uid: user.uid,
        name: "New User",
        phone: "",
        gender: "",
        age: "",
        address: "",
        aadhar: "",
      );

      await usersCollection.doc(user.uid).set(newUser.toMap());
    }

    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
