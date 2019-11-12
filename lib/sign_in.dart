import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount  googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = 
              await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
      );

      await _auth.signInWithCredential(credential);


      final FirebaseUser currentUser = await _auth.currentUser();
      
      
      return currentUser;
    }
    return null;
}

void signOutGoogle() async {
    await googleSignIn.signOut();
    print('User Sign Out');
}

Future<FirebaseUser> signSilentGoogle() async {
   final GoogleSignInAccount googleAcc = await googleSignIn.signInSilently();
   if (googleAcc != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = 
          await googleAcc.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
      );

      await _auth.signInWithCredential(credential);

      final FirebaseUser currentUser = await _auth.currentUser();

      return currentUser;

   }
   return null;
}

Future<dynamic> signIn(String email, String password) async {
  try {
    AuthResult result = await _auth.signInWithEmailAndPassword(
    email: email, password: password,
    );
    FirebaseUser user = result.user;
    if (user != null && user.isEmailVerified) {
      return user;
    }
  }
  catch (e) {
    return e;
  }
  return 'Please verify you email address';
}

Future<dynamic> signUp(String email, String password) async {
  try {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
    email: email, password: password,
    );
    FirebaseUser user = result.user;
    try {
      await user.sendEmailVerification();
      return user;
    }
    catch (e) {
      print(e.toString());
      return e;
    }
  } catch (e) {
    return e;
  }
}

Future<void> forgotPassword(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}

Future<FirebaseUser> getCurrentUser() async {
  return await _auth.currentUser();
}

Future<void> signOut() async {
  return _auth.signOut();
}