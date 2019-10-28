import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'add_manual_shift_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';
import 'sign_in.dart';
import 'login_page.dart';


class MainPage extends StatefulWidget {
  final FirebaseUser user;

  MainPage({Key key, this.user}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
    
  bool _started = false;
  String _income = "0";
  final List<String> months = ["January", "Fabuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  int selectedMonth = 0;
  var currentShiftId = -1;
  int currentYear = 2019;
  double salaryPerHour = 0.0;
  FirebaseUser _user;
  
  ScrollController _controller;
  double _currentStart = -1;

  @override
  void initState() {
     super.initState();
      WidgetsBinding.instance.addObserver(this);
      _user = widget.user;
      String userUid = _user.uid;
      _controller = ScrollController();
      selectedMonth = DateTime.now().month - 1;
      currentYear = DateTime.now().year;
      _getIncome();
      _read();
      WidgetsBinding.instance.addPostFrameCallback((_) {double width = MediaQuery.of(context).size.width; _controller.jumpTo(width * selectedMonth);});
  }
    @override
    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
    }
  
  void _read() async {
    final prefs = await SharedPreferences.getInstance();
    _started = prefs.getBool('StartedShift') ?? false;
    currentShiftId = prefs.getInt('currentShiftId') ?? -1;
    salaryPerHour = prefs.getDouble('SalaryPerHour') ?? 0;
    setState(() {_started = _started;});
  }

  void _save() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('StartedShift', _started);
      prefs.setInt('currentShiftId', currentShiftId);
      prefs.setDouble('SalaryPerHour', salaryPerHour);
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

  bool _scrollMonthCycle(scrollNotification) {
    double width = MediaQuery.of(context).size.width;
    if (scrollNotification is ScrollEndNotification ) {
        if (_currentStart == width * 11 &&_currentStart == scrollNotification.metrics.pixels) {
            _currentStart = 2;
            setState(() {
                currentYear += 1;
                selectedMonth = 0;
            });
            _controller.jumpTo(width * selectedMonth);
            return true;
        }
        if (_currentStart == width * 0  && _currentStart == scrollNotification.metrics.pixels) {
            _currentStart = 2;
            setState(() {
                currentYear -= 1;
                selectedMonth = 11;
            });
            _controller.jumpTo(width * selectedMonth);
            return true;
        }
        int i = (scrollNotification.metrics.pixels / width).round();
        setState(() {selectedMonth = i; _getIncome();});
        return true;
    }
    if (scrollNotification is ScrollStartNotification) {
        if (_currentStart >= 0 ) {
            _currentStart = -1;
            return true;
        }
        if (scrollNotification.metrics.pixels == width * 11 || scrollNotification.metrics.pixels == width * 0 ) {
            _currentStart = scrollNotification.metrics.pixels;
            return true;
        } 
    }
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('Salary Tracker'),
            centerTitle: true,
            backgroundColor: Color(0xff01B47C),
        ),
        drawer: _buildDrawer(context),
        body: Column(
            children: <Widget> [
                Container(
                    height: 50,
                    child: NotificationListener<ScrollNotification>(
                        onNotification: _scrollMonthCycle,
                        child: ListView.builder(
                            controller: _controller,
                            physics: PageScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: months.length,
                            itemBuilder: (context, index) {
                                return Container(
                                        color: Colors.white,
                                        width: width,
                                        child: Center(child: Text('${months[index]} $currentYear'))
                                );
                            }
                        ),
                    ) 
                ),
                Container(
                    color: Color(0xffF2F3F7),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            Text('Day'),
                            Text('Start Time'),
                            Text('End Time'),
                            Text('Income'),
                        ]
                    )
                ),
                Expanded(
                    child: FutureBuilder(
                        future: _getShifts(),
                        builder: _buildShiftsList,
                    )
                ),
                Padding(
                    padding: EdgeInsets.all(40.0),
                ),
                Container(
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
                ),
                 
            ]
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: FloatingActionButton(
                onPressed: _startShift,
                backgroundColor: Color(0xff01B47C),
                child: Icon(_started ? Icons.stop : Icons.play_arrow, color: Colors.white),
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
        return ListView.separated(
            separatorBuilder: (context, index) {
                return Divider(height: 0.0, color: Colors.grey);
            },
            itemCount: shifts.length,
            itemBuilder: (BuildContext context, int index) {
                Shift shift = shifts[index];
                if (shift.endTime == 0) {
                    var date = DateTime.parse(shift.date);
                    var startTime = DateTime.fromMicrosecondsSinceEpoch(shift.startTime);
                    return Container(
                        height: 50.0,
                        color: index % 2 == 0 ? Colors.white : Color(0xffF2F3F7),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget> [
                                Text(date.day.toString()),
                                Text('${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'),
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
                        color: index % 2 == 0 ? Colors.white : Color(0xffF2F3F7),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget> [
                                Text(date.day.toString()),
                                Text('${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'),
                                Text('${endTime.hour.toString().padLeft(2,'0')}:${endTime.minute.toString().padLeft(2, '0')}'),
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
                    UserAccountsDrawerHeader(
                        accountName: Text(_user.displayName),
                        accountEmail: Text(_user.email),
                        currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(_user.photoUrl)),
                    ), 
                    ListTile(
                        title: Text('Add Shift'),
                        onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => AddManualShift()));}
                    ),
                    ListTile(
                        title: Text('Set salary per hour'),
                        onTap: _setSalaryPerHourDialog,
                    ),
                    ListTile(
                        title: Text('Clear all shifts'),
                        onTap: _clearDB,
                    ),
                    ListTile(
                        title: Text('SignOut'),
                        onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())); signOutGoogle(); },
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
                salaryTFController.text = salaryPerHour.toString();
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
