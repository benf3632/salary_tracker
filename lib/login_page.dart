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
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {_silentLogin();});
    }

    void _silentLogin() async {
        Dialogs.showLoadingDialog(context, _keyLoader);
        final prefs = await SharedPreferences.getInstance();
        final bool signed = prefs.getBool('Signed?') ?? false;
        if (signed) {
            var user = await signSilentGoogle();
            if (user != null) {
                Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                Navigator.pushReplacement(context,
                            MaterialPageRoute(
                                builder: (context) => MainPage(user: user)
                            )
                    );
            } else {
                Navigator.of(_keyLoader.currentContext).pop();
            }
        } else {
            if (_keyLoader.currentContext != null) {
                Navigator.of(_keyLoader.currentContext).pop();
            } else {
                Navigator.pop(context);
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        var screenWidth = MediaQuery.of(context).size.width;
        var screenHeight = MediaQuery.of(context).size.height;
        return Scaffold(
                body: Stack(
                    children: <Widget> [
                        ClipPath(
                            child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        stops: [0.1, 0.3, 0.4, 0.5],
                                        colors: [
                                            Colors.orange[300],
                                            Colors.orange[400],
                                            Colors.orange[600],
                                            Colors.orange[900],
                                        ]
                                    ),
                                ),
                                width: screenWidth,
                                height: 300,
                            ),
                            clipper: BottomWaveClipper(),
                        ),
                        Container(
                            child: Text('Login', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
                            margin: EdgeInsets.only(top: 250, left: screenWidth / 2 - 55),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topRight: Radius.circular(50.0), bottomRight: Radius.circular(50.0)),
                                border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget> [
                                    TextField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Username',
                                        )
                                    ), 
                                    Divider(),
                                    TextField(
                                        obscureText: true,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Password',
                                        )
                                    ),
                                ]
                            ),
                            width: 250,
                            height: 105,
                            margin: EdgeInsets.only(top: 360),
                        ),
                        Container(
                            child: _signInButton(),
                            margin: EdgeInsets.only(top: screenHeight - screenHeight / 3, left: screenWidth / 2 + 50),
                        )
                    ]
                )
        );
    }

    Widget _signInButton() {
        return OutlineButton(
            splashColor: Colors.grey,
            onPressed: () {
                signInWithGoogle().then((user) {print('Finished sign in');
                    Navigator.pushReplacement(context,
                            MaterialPageRoute(
                                builder: (context) => MainPage(user: user)
                            )
                    );
                }); 
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            highlightElevation: 0,
            borderSide: BorderSide(color: Colors.grey),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Image(image: AssetImage("assets/google_logo.png"), height: 35),
        );
    }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: Container(
                    key: key,
                    child: SimpleDialog(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      children: <Widget>[
                        Center(
                          child: Column(children: [
                            CircularProgressIndicator(),
                          ]),
                        )
                      ]
                    ),
                    width: 20,
                    height: 20,
              ),
            );
        });
  }
}


class BottomWaveClipper extends CustomClipper<Path> {
    @override
    Path getClip(Size size) {
        var path = Path();
        path.lineTo(0.0, size.height);
        path.quadraticBezierTo(size.width / 2 - 50, size.height - 59, (size.width / 2 ) - 50, size.height / 2 - 30);
        path.quadraticBezierTo(size.width / 2 - 30, 0.0, size.width - 50, 0.0);
        
        path.close();
        return path;
    }

    @override
    bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
