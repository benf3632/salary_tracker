import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount  googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = 
            await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
    );

    await _auth.signInWithCredential(credential);


    final FirebaseUser currentUser = await _auth.currentUser();
    
    print('sign in $currentUser');
    
    return currentUser;
}

void signOutGoogle() async {
    await googleSignIn.signOut();

    print('User Sign Out');
}
