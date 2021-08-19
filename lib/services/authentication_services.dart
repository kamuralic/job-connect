import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:job_connect/services/storage_services.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  StorageService _storageService = new StorageService();

  //For keeping track of if user is still logged in or loged out
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //Current firbase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  //For signing user to the app
  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return 'Signed In';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      }
    }
  }

  //For registering user on the app
  Future<String?> signUp({
    required String email,
    required String password,
    required String userName,
    required String phoneN0,
  }) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((value) => _storageService.addUser(
              // add user to firestore on successful signup
              uid: value.user!.uid,
              email: value.user!.email,
              userName: userName,
              phoneN0: phoneN0));
      return 'Signed Up';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      print(e);
    }
  }

  //For logging out user from the app
  Future<String?> logOut() async {
    await _firebaseAuth.signOut();
    return 'Loged Out';
  }

  Future<String?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential).then(
          (value) => _storageService.addUser(
              uid: value.user!.uid,
              userName: value.user!.displayName,
              email: value.user!.email,
              photoUrl: value.user!.photoURL));
      return 'Signed In';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return 'account-exists-with-different-credential';
      } else if (e.code == 'invalid-credential') {
        return 'invalid-credential!! Please try again';
      }
    } catch (e) {
      print(e);
    }
  }
}
