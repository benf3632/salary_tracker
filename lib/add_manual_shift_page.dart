import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'database_helper_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddManualShift extends StatefulWidget {
  AddManualShift({Key key, this.helper}) : super(key: key);

  final DatabaseHelper helper;
  @override
  _AddManualShiftState createState() => _AddManualShiftState();
}

class _AddManualShiftState extends State<AddManualShift> {
  var _startTime;
  var _endTime;
  var _income;
  DatabaseHelper helper;

  @override
  void initState() {
    super.initState();
    helper = widget.helper;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var wageTEController = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Shift', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Color(0xff01B47C),
        ),
        body: Column(children: [
          Container(
            child: Text('Start Time:'),
            margin: EdgeInsets.only(top: 20, right: screenWidth - 150),
            padding: EdgeInsets.only(bottom: 5),
          ),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
              ),
              width: screenWidth - 50,
              height: 50,
              child: Container(
                child:
                    Text('${_startTime != null ? _startTime.toString() : ''}'),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 10),
              ),
              margin: const EdgeInsets.only(right: 20, left: 20),
              padding: const EdgeInsets.only(top: 10),
            ),
            onTap: () => _showDateTimePicker(false),
          ),
          Container(
            child: Text('End Time:'),
            padding: EdgeInsets.only(bottom: 5.0),
            margin: EdgeInsets.only(top: 20.0, right: screenWidth - 150),
          ),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
              ),
              width: screenWidth - 50,
              height: 50,
              child: Container(
                child: Text('${_endTime != null ? _endTime.toString() : ''}'),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 10),
              ),
              margin: const EdgeInsets.only(right: 20, left: 20),
              padding: const EdgeInsets.only(top: 20),
            ),
            onTap: () => _showDateTimePicker(true),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Hourly Wage',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40.0))),
              ),
              onChanged: (wage) {
                double temp = double.tryParse(wage);
                if (temp == null) {
                  wageTEController.text = '';
                } else {
                  _income = temp;
                }
              },
              controller: wageTEController,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            width: screenWidth / 2,
            padding: const EdgeInsets.only(top: 20.0),
          ),
          ElevatedButton(
            child: Text('Add Shift'),
            onPressed: _addShift,
          ),
        ]));
  }

  void _showDateTimePicker(bool option) {
    DatePicker.showDateTimePicker(context,
        showTitleActions: true, currentTime: DateTime.now(), onConfirm: (date) {
      setState(() {
        if (option) {
          _endTime = date;
        } else {
          _startTime = date;
        }
      });
    });
  }

  void _addShift() async {
    if (_startTime == null || _endTime == null || _income == null) {
      Fluttertoast.showToast(
        msg: 'Please Fill all fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
      return;
    }
    var startTime = _startTime.microsecondsSinceEpoch;
    var endTime = _endTime.microsecondsSinceEpoch;
    var hoursWorked = (endTime - startTime) / 1000000;
    hoursWorked /= 3600;
    var income = hoursWorked * _income;
    Shift shift = Shift(startTime, endTime, _startTime.toString(), income);
    String id = await helper.insert(shift);
    shift.id = id;
    helper.update(shift);
    Navigator.pop(context);
  }
}
