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
