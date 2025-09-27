
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to monitor user authentication state changes
  // Returns a stream of User objects (null if logged out)
  Stream<User?> get userChanges => _auth.authStateChanges();

  /// Handles user sign-up with email and password.
  /// Automatically creates a basic Firestore profile upon successful sign-up.
  Future<User?> signUp(String email, String password) async {
    try {
      // 1. Create the user account in Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // 2. Create a basic profile document in Firestore under 'users/{uid}'
        await _createBasicProfile(user);
        print('User signed up and profile created for UID: ${user.uid}');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Handle common Firebase Auth errors
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return null;
    } catch (e) {
      print('An unknown error occurred during sign-up: $e');
      return null;
    }
  }

  /// Handles user sign-in with email and password.
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in: ${userCredential.user!.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle common Firebase Auth errors (e.g., wrong-password, user-not-found)
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return null;
    }
  }

  /// Handles user sign-out.
  Future<void> signOut() async {
    await _auth.signOut();
    print('User signed out.');
  }

  // Minimal helper that creates a basic user document in Firestore.
  // Adjust fields as needed by your app schema.
  Future<void> _createBasicProfile(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': user.displayName ?? '',
        // add other default fields here
      });
    }
  }
}