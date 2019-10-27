import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';


class AddManualShift extends StatefulWidget {
    AddManualShift({Key key}) : super(key: key);

    @override
    _AddManualShiftState createState() => _AddManualShiftState();
}


class _AddManualShiftState extends State<AddManualShift> {

    var _startTime = null;
    var _endTime = null;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Add Shift', style: TextStyle(color: Colors.white)),
                centerTitle: true,
                backgroundColor: Color(0xff01B47C),
            ),
            body: Column(
                    children: [
                        Text('Start Time: '),
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            width: 300,
                            height: 25,
                            margin: const EdgeInsets.all(35.0),
                            child: Text(''),
                        )
                    ]
                )
        );
    }
}
