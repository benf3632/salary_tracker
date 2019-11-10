import 'package:flutter/material.dart';
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
        resizeToAvoidBottomInset: false,
        body: Stack(
            children: <Widget> [
              AnimatedCrossFade(
                duration: Duration(milliseconds: 500),
                firstChild: _loginStack(screenWidth, screenHeight),
                secondChild: Container(
                  child: RaisedButton(
                    child: Text('Login'),
                    onPressed: () {
                      setState(() {
                       _registerScreen = false; 
                      });
                    },
                  ),
                  margin: EdgeInsets.only(top: screenHeight / 2, left: screenWidth / 2),
                ),
                crossFadeState: _registerScreen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              ),
              _waveDesStack(screenWidth, screenHeight),
              
            ]
        )
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
                      decoration: InputDecoration(
                          border: InputBorder.none,                                    
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Username',
                      )
                    ),
                  ), 
                  Divider(),
                  Theme(
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                    child: TextField(
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
          child: RaisedButton(
            child: Text('Register'),
            color: Colors.white,
            onPressed: () {
              setState(() {
               _registerScreen = true; 
              });
            },
          ),
          margin: EdgeInsets.only(top: screenHeight - screenHeight / 3, left: screenWidth / 4.50),
        ),
        Container(
            child: FloatingActionButton(
              heroTag: "Login",
                child: Icon(Icons.arrow_forward),
                backgroundColor: Colors.greenAccent,
                onPressed: () {}
            ),
            margin: EdgeInsets.only(top: 390, left: screenWidth - 150)
        ),
      ],
    );
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
                      builder: (context) => MainPage(user: user)
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




