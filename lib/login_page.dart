import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
    LoginPage({Key key}) : super(key: key);
    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    
    @override
    void initState() {
        super.initState();
        _silentLogin();
    }

    void _silentLogin() async {
        final prefs = await SharedPreferences.getInstance();
        final bool signed = prefs.getBool('Signed?') ?? false;
        if (signed) {
            var user = await signSilentGoogle();
            if (user != null) {
                Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => MainPage(user: user)
                            )
                    );
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
                body: Container(
                    color: Colors.white,
                    child: Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget> [
                                    _signInButton(),
                                ]
                            )
                    )
                )
        );
    }

    Widget _signInButton() {
        return OutlineButton(
            splashColor: Colors.grey,
            onPressed: () {
                signInWithGoogle().then((user) {print('Finished sign in');
                    Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => MainPage(user: user)
                            )
                    );
                }); 
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            highlightElevation: 0,
            borderSide: BorderSide(color: Colors.grey),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                                'Sign in with Google',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                ),
                            )
                        )
                    ]
                ),
            )
        );
    }
}
