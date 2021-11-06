import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount != null) {
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    await _auth.signInWithCredential(credential);
    return _auth.currentUser;
  }
  return null;
}

void signOutGoogle() async {
  await googleSignIn.signOut();
  print('User Sign Out');
}

Future<User> signSilentGoogle() async {
  final GoogleSignInAccount googleAcc = await googleSignIn.signInSilently();
  if (googleAcc != null) {
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleAcc.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    await _auth.signInWithCredential(credential);
    return _auth.currentUser;
  }
  return null;
}

Future<dynamic> signIn(String email, String password) async {
  try {
    User user = (await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
    if (user != null && user.emailVerified) {
      return user;
    }
  } catch (e) {
    return e;
  }
  return 'Please verify you email address';
}

Future<dynamic> signUp(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User user = userCredential.user;
    try {
      await user.sendEmailVerification();
      return user;
    } catch (e) {
      print(e.toString());
      return e;
    }
  } catch (e) {
    return e;
  }
}

Future<dynamic> forgotPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    return true;
  } catch (e) {
    return e;
  }
}

User getCurrentUser() {
  return _auth.currentUser;
}

Future<void> signOut() async {
  return _auth.signOut();
}
