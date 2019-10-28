import 'package:cloud_firestore/cloud_firestore.dart';

final String coulmnId = '_id';
final String coulmnStartTime = 'start_time';
final String coulmnEndTime = 'end_time';
final String coulmnDate = 'date';
final String coulmnIncome = 'income';
final String tableShifts = 'shifts';

class Shift {
    String id;
    var startTime;
    var endTime;
    String date;
    var income;
    
    Shift(this.startTime, this.endTime, this.date, this.income);

    Shift.fromMap(Map<String, dynamic> map) {
        id = map[coulmnId];
        startTime = map[coulmnStartTime];
        endTime = map[coulmnEndTime];
        date = map[coulmnDate];
        income = map[coulmnIncome];
    }

    Map<String, dynamic> toMap() {
        var map = <String, dynamic> {
            coulmnStartTime: startTime,
            coulmnEndTime: endTime,
            coulmnIncome: income,
            coulmnDate: date,
            coulmnId: id,
        };
        return map;
    }
}

class DatabaseHelper {
    final String collectionId;
    DatabaseHelper({this.collectionId});
    
    final databaseReference = Firestore.instance;

    Future<String> insert(Shift shift) async {
        DocumentReference dr = await 
                databaseReference.collection(collectionId).add(shift.toMap());
        return dr.documentID;
    } 

    Future<List<Shift>> queryShiftsByMonthAndYear(int month, int year) async {
        String monthStr = month.toString().padLeft(2, '0');
        String yearStr = year.toString();
        databaseReference.collection(collectionId).getDocuments().then((QuerySnapshot snapshot) {
            snapshot.documents.forEach((f) {
                
            });
        });
    }
}
