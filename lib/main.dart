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
  String _income = "0";

  @override
  void initState() {
      // Calc income and set it
      // pull local config
      // pull shift from database
      print("start");
     super.initState();
  }

  @override
  void dispose() {
      // save local config
      print('stop');
      super.dispose();
  }
  List<String> months = ["January", "Fabuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  String selctedMonth = "";
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
                                    setState(() {selctedMonth = months[i];});
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
                        child: Center(child: Text(selctedMonth)),
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
