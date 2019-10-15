import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Tracker',
      home: MyHomePage(title: 'Salary Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
    
  bool _started = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
            backgroundColor: Colors.black,
        ),
        body: Column(
            children: <Widget> [
                 Container(
                    width: 400,
                    height: 48,
                    alignment: Alignment.bottomCenter,
                    color: Colors.white,
                        child: Row(
                            children: <Widget>[
                                Text('Total Income'),
                                Text('5000', style: TextStyle(color: Colors.green)),
                            ]
                        ) 
                )
            ]
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: FloatingActionButton(
                onPressed: _startShift,
                backgroundColor: Colors.white,
                child: Icon(_started ? Icons.stop : Icons.play_arrow, color: Colors.black),
            ),
        ) 
    );
}

  void _startShift() async{
      bool didAuth = await _auth();
      if (didAuth) {
          if (!_started) {
            print("Shift Started\n");
          } else {
            print("Shift Stopped\n");
          }
          setState(() {_started = !_started;});
          
      }
  }

  Future<bool> _auth() async{
    var localAuth = LocalAuthentication();
    bool didAuth = false;
    try {
        didAuth = await localAuth.authenticateWithBiometrics(
            localizedReason: 'To Start your shift autherize',
            stickyAuth: true,
        );
    } catch (e) {

    }
    
    return didAuth;
  }
}
