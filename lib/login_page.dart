import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wave/config.dart';
import 'sign_in.dart';
import 'main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/wave.dart';


class LoginPage extends StatefulWidget {
    LoginPage({Key key}) : super(key: key);
    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool _registerScreen = false;
  Map<String, TextEditingController> _textControllers = {
    'LoginUsername': TextEditingController(),
    'LoginPassword': TextEditingController(),
    'RegisterPassword': TextEditingController(),
    'RegisterConfirm': TextEditingController(),
    'RegisterEmail': TextEditingController(),
  };

  @override
  void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {_silentLogin();});
  }

  void _silentLogin() async {
      Dialogs.showLoadingDialog(context, _keyLoader);
      final prefs = await SharedPreferences.getInstance();
      final int signed = prefs.getInt('Signed?') ?? 0;
      if (signed == 1) {
          var user = await signSilentGoogle();
          if (user != null) {
              Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
              Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (context) => MainPage(user: user, signMethod: 1),
                )
              );
          } else {
              Navigator.of(_keyLoader.currentContext).pop();
          }
      } else if (signed == 2) {
        var user = await getCurrentUser();
        if (user != null) {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
            Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (context) => MainPage(user: user, signMethod: 2),
              )
          );
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
        resizeToAvoidBottomInset: false,
        body: Stack(
            children: <Widget> [
                _registerScreen
                  ? _registerStack(screenWidth, screenHeight)
                  : _loginStack(screenWidth, screenHeight),
              _waveDesStack(screenWidth, screenHeight),
            ]
        )
      );
  }

  Widget _registerStack(double screenWidth, double screenHeight) {
    return Stack(
      children: <Widget>[
        Container(
          child: Text('Register', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
          margin: EdgeInsets.only(top: 200, left: screenWidth / 2 - 95),
        ),
        Container(
          width: 100,
          height: 50,
          child: RaisedButton(
            child: Text('Login', style: TextStyle(color: Colors.pink[500]),),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0)
            ),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _registerScreen = false; 
              });
            },
          ),
        margin: EdgeInsets.only(top: screenHeight - screenHeight / 3),
        ),
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(50.0), bottomRight: Radius.circular(50.0)),
                border: Border.all(color: Colors.grey),
            ),
            child: Column(                    
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                  Theme(
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                    child: TextField(
                      controller: _textControllers['RegisterEmail'],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.alternate_email),
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  Divider(),
                  Theme(
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                    child: TextField(
                      controller: _textControllers['RegisterPassword'],
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Password',
                      )
                    ),
                  ),
                  Divider(),
                  Theme(
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                    child: TextField(
                      controller: _textControllers['RegisterConfirm'],
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Confirm Password',
                      )
                    ),
                  )
              ]
            ),
            width: screenWidth / 1.15,
            height: 178,
            margin: EdgeInsets.only(top: screenHeight / 3),
        ),
        Container(
          margin: EdgeInsets.only(top: screenHeight / 2 - 50, left: screenWidth - 75),
          child: FloatingActionButton(
            heroTag: "Register",
            child: Icon(Icons.check),
            backgroundColor: Colors.greenAccent,
            onPressed: _register,
          ),
        )
      ],
    );
  }

  Widget _waveDesStack(double screenWidth, double screenHeight) {
    return Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          Container(
              height: 200,
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(180 / 360),
                child: WaveWidget(
                  config: CustomConfig(
                    gradients: [
                      [Colors.red, Color(0xEEF44336)],
                      [Colors.red[800], Color(0x77E57373)],
                      [Colors.orange, Color(0x66FF9800)],
                      [Colors.yellow, Color(0x55FFEB3B)]
                    ],
                    durations: [35000, 19440, 10800, 6000],
                    heightPercentages: [0.20, 0.23, 0.25, 0.30],
                    blur: MaskFilter.blur(BlurStyle.solid, 10),
                    gradientBegin: Alignment.bottomLeft,
                    gradientEnd: Alignment.topRight,
                  ),
                  waveAmplitude: 0,
                  size: Size(
                    double.infinity,
                    double.infinity,
                  ),
                ),
              )
            ),
            Container(
              height: 200,
              margin: EdgeInsets.only(top:screenHeight - 400),
              child: WaveWidget(
                config: CustomConfig(
                  gradients: [
                    
                    [Colors.blue, Color(0xFF12EBC5)],
                    [Colors.blue, Colors.blue[500]],
                    [Colors.blueAccent, Colors.yellow],
                    [Colors.blue, Colors.green],
                  ],
                  durations: [35000, 19440, 10800, 6000],
                  heightPercentages: [0.20, 0.23, 0.25, 0.30],
                  blur: MaskFilter.blur(BlurStyle.solid, 10),
                  gradientBegin: Alignment.bottomLeft,
                  gradientEnd: Alignment.topRight,
                ),
                waveAmplitude: 0,
                size: Size(
                  double.infinity,
                  double.infinity,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _loginStack(double screenWidth, double screenHeight) {
    return Stack(
      children: <Widget>[
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
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                  Theme(
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                    child: TextField(
                      controller: _textControllers['LoginUsername'],                                           
                      decoration: InputDecoration(
                          border: InputBorder.none,                                    
                          prefixIcon: Icon(Icons.alternate_email),
                          hintText: 'Email',
                      )
                    ),
                  ), 
                  Divider(),
                  Theme(
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                    child: TextField(
                      controller: _textControllers['LoginPassword'],
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Password',
                      )
                    ),
                  ),
              ]
            ),
            width: 250,
            height: 120,
            margin: EdgeInsets.only(top: 360),
        ),
        Container(
            child: _signInButton(),
            margin: EdgeInsets.only(top: 390, left: screenWidth - 80),
        ),
        Container(
          width: 100,
          height: 50,
          child: RaisedButton(
            child: Text('Register', style: TextStyle(color: Colors.pink[500])),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
            ),
            color: Colors.white,
            onPressed: () {
              setState(() {
               _registerScreen = true; 
              });
            },
          ),
          margin: EdgeInsets.only(top: screenHeight - screenHeight / 3),
        ),
        Container(
            child: FloatingActionButton(
              heroTag: "Login",
              child: Icon(Icons.arrow_forward),
              backgroundColor: Colors.greenAccent,
              onPressed: _login,
            ),
            margin: EdgeInsets.only(top: 390, left: screenWidth - 150)
        ),
        GestureDetector(
          child: Container(
            child: Text('Forgot?', style: TextStyle(color: Colors.grey),),
            margin: EdgeInsets.only(top: screenHeight / 2 + 70, left: screenWidth - screenWidth / 2),
          ),
          onTap: () async {
            TextEditingController emailTEC = TextEditingController();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Forgot Password'),
                  content: TextField(
                    controller: emailTEC,
                    decoration: InputDecoration(
                      hintText: 'Email',
                    ),
                    autofocus: true,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Send Reset'),
                      onPressed: () async {
                        Dialogs.showLoadingDialog(context, _keyLoader);
                        String email = emailTEC.text;
                        var res = await forgotPassword(email);
                        if (res is bool && res) {
                          Fluttertoast.showToast(
                            msg: 'Email sent with password reset',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: res.message,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                        }
                        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              }
            );
          },
        )
      ],
    );
  }

  void _login() async {
    String email = _textControllers['LoginUsername'].text ?? "";
    String password = _textControllers['LoginPassword'].text ?? "";
    Dialogs.showLoadingDialog(context, _keyLoader);
    var user = await signIn(email, password);
    if (user is FirebaseUser) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => MainPage(user: user, signMethod: 2)
        )
      );
    } else {
      if (_keyLoader.currentContext != null) {
        Navigator.of(_keyLoader.currentContext).pop();
      } else {
        Navigator.pop(context);
      }
      if (user is String) {
        Fluttertoast.showToast(
        msg: user,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 14.0,
        );
      } else {
        Fluttertoast.showToast(
        msg: user.message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 14.0,
        );
      }
    }
  }

  void _register() async {
    String email = _textControllers['RegisterEmail'].text ?? "";
    String password = _textControllers['RegisterPassword'].text ?? "";
    String confirm = _textControllers['RegisterConfirm'].text ?? "";
    if (password != confirm) {
      Fluttertoast.showToast(
        msg: "Passwords don't match",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }
    Dialogs.showLoadingDialog(context, _keyLoader);
    var user = await signUp(email, password);
    if (user is FirebaseUser) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      setState(() {
        _registerScreen = false;
      });
      Fluttertoast.showToast(
        msg: 'Please Verify your email now and Login',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } else {
      if (_keyLoader.currentContext != null) {
        Navigator.of(_keyLoader.currentContext).pop();
      } else {
        Navigator.pop(context);
      }
      Fluttertoast.showToast(
        msg: user.message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Widget _signInButton() {
      return FloatingActionButton(
          heroTag: "GoogleLogin",
          splashColor: Colors.grey,
          backgroundColor: Colors.white,
          onPressed: () {
              signInWithGoogle().then((user) {
                if (user != null) {
                  print('Finished sign in');
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(user: user, signMethod: 1)
                    )
                  );
                }
              }); 
          },
          child: Image(image: AssetImage("assets/google_logo.png"), height: 35),
      );
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(BuildContext context, GlobalKey key) async {
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
      }
    );
  }
}




