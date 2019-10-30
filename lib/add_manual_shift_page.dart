import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';


class AddManualShift extends StatefulWidget {
    AddManualShift({Key key}) : super(key: key);

    @override
    _AddManualShiftState createState() => _AddManualShiftState();
}


class _AddManualShiftState extends State<AddManualShift> {

    var _startTime;
    var _endTime;

    @override
    Widget build(BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return Scaffold(
            appBar: AppBar(
                title: Text('Add Shift', style: TextStyle(color: Colors.white)),
                centerTitle: true,
                backgroundColor: Color(0xff01B47C),
            ),
            body: Column(
                    children: [
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
                                    child: Text('${_startTime != null ? _startTime.toString() : ''}'),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(bottom: 10),
                                ),
                                margin: const EdgeInsets.only(right: 20, left: 20),
                                padding: const EdgeInsets.only(top: 10),
                            ),
                            onTap: () => _showDateTimePicker(false),
                        ),
                    ]
                )
        );
    }

    void _showDateTimePicker(bool option) {
        DatePicker.showDateTimePicker(context,
            showTitleActions: true,
            currentTime: DateTime.now(),
            onConfirm: (date) {
                setState(() {
                    if (option) {
                        _endTime = date;
                    } else {
                        _startTime = date;
                    }
                });
                print(_startTime.toString());
            }
        );
    }
}
