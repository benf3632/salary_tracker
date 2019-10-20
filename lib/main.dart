import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'dart:core';

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
  final List<String> months = ["January", "Fabuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  int selectedMonth = 0;
  int currentShiftId;
  int currentYear = 2019;
  double salaryPerHour;

  @override
  void initState() {
     super.initState();
      WidgetsBinding.instance.addObserver(this);
      selectedMonth = DateTime.now().month - 1;
      salaryPerHour = 0;
      _getIncome();
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
        drawer: _buildDrawer(context),
        body: Column(
            children: <Widget> [
                Container(
                    height: 50,
                    child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                                if (scrollNotification is ScrollEndNotification) {
                                    int i = (scrollNotification.metrics.pixels / width).round();
                                    setState(() {selectedMonth = i;});
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
                Expanded(
                    child: FutureBuilder(
                        future: _getShifts(),
                        builder: _buildShiftsList,
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
    Future<List<Shift>> _getShifts() async {
        DatabaseHelper helper = DatabaseHelper.instance;
        List<Shift> shifts = await helper.queryShiftsByMonthAndYear(selectedMonth + 1, currentYear);
        return shifts;
    }

    Widget _buildShiftsList(BuildContext context, AsyncSnapshot snapshot) {
        List<Shift> shifts = snapshot.data ?? [];
        return ListView.builder(
            itemCount: shifts.length,
            itemBuilder: (BuildContext context, int index) {
                Shift shift = shifts[index];
                if (shift.endTime == 0) {
                    var date = DateTime.parse(shift.date);
                    var startTime = DateTime.fromMicrosecondsSinceEpoch(shift.startTime);
                    return Container(
                        height: 50.0,
                        color: Colors.white,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget> [
                                Text(date.day.toString()),
                                Text('${startTime.hour.toString()}:${startTime.minute.toString()}'),
                                Text('Shift On Progress'),
                            ]
                        ),
                    );
                } else {
                    var date = DateTime.parse(shift.date);
                    var startTime = DateTime.fromMicrosecondsSinceEpoch(shift.startTime);
                    var endTime = DateTime.fromMicrosecondsSinceEpoch(shift.endTime);
                    return Container(
                        height: 50.0,
                        color: Colors.white,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget> [
                                Text(date.day.toString()),
                                Text('${startTime.hour.toString()}:${startTime.minute.toString()}'),
                                Text('${endTime.hour.toString()}:${endTime.minute.toString()}'),
                                Text(shift.income.toStringAsFixed(2)),
                            ]
                        ),
                    );
                }
            }
        );
    }

   void _getIncome() async {
        DatabaseHelper helper = DatabaseHelper.instance;
        double income = await helper.getAllIncomeByDate(selectedMonth + 1, currentYear);
        setState(() {_income = income.toStringAsFixed(2);});

    }

  void _startShift() async{
      bool didAuth = await _auth();
      if (didAuth) {
          DatabaseHelper helper = DatabaseHelper.instance;
          if (_started) {
              DateTime time = DateTime.now();
              Shift shift = await helper.queryShift(currentShiftId);
              shift.endTime = time.microsecondsSinceEpoch;
              shift.id = currentShiftId;
              var hoursWorked = (shift.endTime - shift.startTime) / 1000000;
              hoursWorked = hoursWorked / 3600;
              var income = hoursWorked * salaryPerHour;
              shift.income = income;
              helper.update(shift);
          } else {
             DateTime time = DateTime.now();
             Shift shift = Shift(time.microsecondsSinceEpoch,0,time.toString(),0);
             int id = await helper.insert(shift);
             currentShiftId = id;
          }
          await _getIncome();
          setState(() {_started = !_started; });

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
  
    void _clearDB() async {
        DatabaseHelper helper = DatabaseHelper.instance;
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                        title: Text('Confirmation'),
                        content: Text('Are you sure you want to delete your shift?'),
                        actions: <Widget>[
                            FlatButton(
                                child: Text('CLEAR!'),
                                onPressed: () {
                                    helper.clear();
                                    setState(() {_started = false;});
                                    Navigator.of(context).pop();
                                }
                            ),
                            FlatButton(
                                child: Text('CANCEL'),
                                onPressed: () {
                                    Navigator.of(context).pop();
                                }
                            ),
                        ],
                );
            }
        );
    }

    Widget _buildDrawer(BuildContext context) {
        return Drawer(
            child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                    DrawerHeader(
                        child: Text('Menu'),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                        ),
                        
                    ),
                    ListTile(
                        title: Text('Set salary per hour'),
                        onTap: _setSalaryPerHourDialog,
                    ),
                    ListTile(
                        title: Text('Clear all shifts'),
                        onTap: _clearDB,
                    )
                ]
            )
        );
    }
    
    Future<Null> _setSalaryPerHourDialog() async {
        var salaryTFController = TextEditingController();
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('Set your salary per hour'),
                    content: TextField(
                            controller: salaryTFController,
                            autofocus: true,
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text('Done'),
                            onPressed: () {
                                var temp = double.tryParse(salaryTFController.text);
                                if (temp != null) {
                                    salaryPerHour = temp;
                                    Navigator.of(context).pop();
                                } else {
                                    salaryTFController.text = 'Only numbers';
                                }
                            }
                        )
                    ]
                );
            }
        );
    }
}
