import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  
    
  bool _started = false;
  String _income = "0";
  List<String> months = ["January", "Fabuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  int selectedMonth = 0;
  int currentShift;

  @override
  void initState() {
     super.initState();
      WidgetsBinding.instance.addObserver(this);
      _read();
      // Calc income and set it
      // pull shift from database
  }
  
  void _read() async {
    final prefs = await SharedPreferences.getInstance();
    _started = prefs.getBool('StartedShift') ?? false;
    setState(() {_started = _started;});
  }

  @override
  void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
      switch (state) {
          case AppLifecycleState.inactive:
          case AppLifecycleState.paused:
          case AppLifecycleState.suspending:
              _save();
              break;
          case AppLifecycleState.resumed:
              break;
      }
  }
  
  void _save() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('StartedShift', _started);
  }
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                    height: 50,
                    child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                                if (scrollNotification is ScrollEndNotification) {
                                    int i = (scrollNotification.metrics.pixels / width).round();
                                    setState(() {selctedMonth = i;});
                                }
                                return true;
                            },
                        child: ListView.builder(
                            physics: PageScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: months.length,
                            itemBuilder: (context, index) {
                                return Container(
                                        color: Colors.white,
                                        width: width,
                                        child: Center(child: Text(months[index]))
                                );
                            }
                        ),
                    ) 
                ),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                        height: 50,
                        width: width,
                        child: Center(child: Text(months[selectedMonth])),
                        color: Colors.white,
                    )
                ),
                Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                            width: width,
                            height: 48,
                            color: Colors.white,
                            child: Row(
                                children: <Widget>[
                                    Padding(padding: const EdgeInsets.all(20.0)),
                                    Text('Total Income', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                                    Padding(padding: const EdgeInsets.all(70.0)),
                                    Text(_income, style: TextStyle(color: Colors.green, fontSize: 20.0, fontWeight: FontWeight.bold)),
                                ]
                            ) 
                        )
                    )
                ),
                 
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
          if (_started) {

          } else {
              
          }
          setState(() {_started = !_started;});

      }
  }

  Future<bool> _auth() async{
    var localAuth = LocalAuthentication();
    bool didAuth = false;
    try {
        didAuth = await localAuth.authenticateWithBiometrics(
            localizedReason: _started ? 'To Stop your Shift' : 'To Start your shift',
        );
    } catch (e) {

    }
    
    return didAuth;
  }
}
