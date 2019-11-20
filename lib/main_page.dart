import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper_firestore.dart';
import 'add_manual_shift_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:core';
import 'sign_in.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  final FirebaseUser user;
  final int signMethod;

  MainPage({Key key, this.user, this.signMethod}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
    
  bool _started = false;
  String _income = "0";
  final List<String> months = ["January", "Fabuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  int selectedMonth = 0;
  var currentShiftId = '';
  int currentYear = 2019;
  double salaryPerHour = 0.0;
  FirebaseUser _user;
  DatabaseHelper helper;
  int _signed = 0;
  
  ScrollController _controller;
  double _currentStart = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _user = widget.user;
    String userUid = _user.uid;
    helper = DatabaseHelper(userUid);
    _controller = ScrollController();
    selectedMonth = DateTime.now().month - 1;
    currentYear = DateTime.now().year;
    _getIncome();
    _read();
    _signed = widget.signMethod;
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
    currentShiftId = prefs.getString('currentShiftId') ?? '';
    salaryPerHour = prefs.getDouble('SalaryPerHour') ?? 0;
    setState(() {_started = _started;});
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('StartedShift', _started);
    prefs.setString('currentShiftId', currentShiftId);
    prefs.setDouble('SalaryPerHour', salaryPerHour);
    prefs.setInt('Signed?', _signed);
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            color: Color(0xfff2f3f7),
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
    List<Shift> shifts = await helper.queryShiftsByMonthAndYear(selectedMonth + 1, currentYear);
    return shifts;
  }

  Widget _buildShiftsList(BuildContext context, AsyncSnapshot snapshot) {
    List<Shift> shifts = snapshot.data ?? [];
    shifts.sort((a, b) => a.startTime.compareTo(b.startTime));
    return ListView.separated(
      separatorBuilder: (context, index) {
          return Divider(height: 0.0, color: Colors.grey);
      },
      itemCount: shifts.length,
      itemBuilder: (BuildContext context, int index) {
        Shift shift = shifts[index];
        
        Color color = index % 2 == 0 ? Colors.white : Color(0xfff2f3f7);
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.18,
          child: Container(
            height: 50.0,
            color: color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[..._rowShift(shift),]
            ),
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Edit',
              color: Colors.grey,
              icon: Icons.edit,
              onTap: () => _modifyShift(shift),
            ),
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => _deleteShift(shift),
              closeOnTap: false,
            )
          ],
        );
      }
    );
  }
  List<Widget> _rowShift(Shift shift) {
    var date = DateTime.parse(shift.date);
    var startTime = DateTime.fromMicrosecondsSinceEpoch(shift.startTime);
    var endTime = DateTime.fromMicrosecondsSinceEpoch(shift.endTime);
    return shift.endTime == 0 ?
      <Widget> [
      Text(date.day.toString()),
      Text('${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'),
      Text('Shift On Progress'),
    ] :  
    <Widget> [
      Text(date.day.toString()),
      Text('${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'),
      Text('${endTime.hour.toString().padLeft(2,'0')}:${endTime.minute.toString().padLeft(2, '0')}'),
      Text(shift.income.toStringAsFixed(2)),
    ];
  }
  
  void _modifyShift(Shift shift) async {
    final DateTime currentStartTime = DateTime.fromMicrosecondsSinceEpoch(shift.startTime);
    final DateTime currentEndTime = DateTime.fromMicrosecondsSinceEpoch(shift.endTime);
    DateTime startTime = currentStartTime;
    print(startTime);
    DateTime endTime = currentEndTime;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Text('Modify Shift'),
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Text('Start Time'),
                ),
                InkWell(
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      ),
                      width: 300,
                      height: 50,
                      child: Container(
                          child: Text('${startTime != null ? DateFormat('yyyy-MM-dd kk:mm:ss').format(startTime) : ''}'),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(bottom: 10),
                      ),
                      margin: const EdgeInsets.only(right: 20, left: 20),
                      padding: const EdgeInsets.only(top: 20),
                  ),
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      currentTime: startTime,
                      onChanged: (date) {
                        setState(() {
                          startTime = date;
                        });                      
                      }
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('End Time'),
                  ), 
                ),
                InkWell(
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      ),
                      width: 300,
                      height: 50,
                      child: Container(
                          child: Text('${endTime != null ? DateFormat('yyyy-MM-dd kk:mm:ss').format(endTime) : ''}'),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(bottom: 10),
                      ),
                      margin: const EdgeInsets.only(right: 20, left: 20),
                      padding: const EdgeInsets.only(top: 20),
                  ),
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      currentTime: startTime,
                      onChanged: (date) {
                        setState(() {
                          endTime = date;
                        });                      
                      }
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        child: TextField(
                          decoration: InputDecoration(
                              labelText: 'Wage',
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40.0))),
                          ),
                          onChanged: (wage) {
                              
                          },
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(40.0))
                        ),
                        width: 100
                      ),
                      Container(
                        child: TextField(
                          decoration: InputDecoration(
                              labelText: 'Period',
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40.0))),
                          ),
                          onChanged: (wage) {
                              
                          },
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(40.0))
                        ),
                        width: 100
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: FlatButton(
                    child: Text('Update'),
                    onPressed: () {},
                  ),
                ),
              ],
            );
          }
        );
      },
    );          
    setState(() {
      _started = _started;
    });
  }

  void _deleteShift(Shift shift) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to delete this shift?'),
        actions: <Widget>[
          FlatButton(
            child: Text('Delete!'),
            onPressed: () async {
    await helper.delete(shift.id);
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
    setState(() {
      _started = _started;
    });
  }

  Future<void> _getIncome() async {
    double income = await helper.getAllIncomeByDate(selectedMonth + 1, currentYear);
    setState(() {_income = income.toStringAsFixed(2);});
  }

  void _startShift() async{
    bool didAuth = await _auth();
    if (didAuth) {
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
        String id = await helper.insert(shift);
        currentShiftId = id;
      }
      await _getIncome();
      setState(() {_started = !_started; });
    }
  }

  Future<bool> _auth() async {
    var localAuth = LocalAuthentication();
    bool didAuth = false;
    List<BiometricType> availBiometrics = await localAuth.getAvailableBiometrics();
    if (availBiometrics.length > 0) {
      try {
      didAuth = await localAuth.authenticateWithBiometrics(
        localizedReason: _started ? 'To Stop your Shift' : 'To Start your shift',
      );
      } catch (e) {}
    }
    return didAuth;
  }
  
  void _clearDB() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete your shifts?'),
          actions: <Widget>[
            FlatButton(
              child: Text('CLEAR!'),
              onPressed: () async {
                await helper.clear();
                setState(() {_started = false;});
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            ),
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
              }
            ),
          ],
        );
      }
    );
    setState(() {
      _started = _started;
    });
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _signed == 1 ? 
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
              ), 
              accountName: Text(_user.displayName),
              accountEmail: Text(_user.email),
              currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(_user.photoUrl)),
          ) :
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.greenAccent,
            ),
            accountEmail: Text(_user.email),
            accountName: Text(_user.email.substring(0, _user.email.indexOf('@'))),
          ), 
          ListTile(
              title: Text('Add Shift'),
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => AddManualShift(helper: helper)));}
          ),
          ExpansionTile(
            title: Text('Settings'),
            children: <Widget> [
              ListTile(
              title: Text('Set salary per hour'),
              onTap: _setSalaryPerHourDialog,
              ),
              ListTile(
                  title: Text('Clear all shifts'),
                  onTap: _clearDB,
              ),
            ]
          ),
          ListTile(
              title: Text('Signout'),
              onTap: _signOut,
          )
        ]
      )
    );
  }

  void _signOut() async {
    if (_signed == 1) {
      signOutGoogle();
    } else if (_signed == 2) {
      signOut();
    }
    _signed = 0;
    await _save();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())); 
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
