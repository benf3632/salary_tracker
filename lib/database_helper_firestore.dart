import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';

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
    DatabaseHelper(this.collectionId);
    
    final databaseReference = Firestore.instance;

    Future<String> insert(Shift shift) async {
        DocumentReference dr = await 
                databaseReference.collection(collectionId).add(shift.toMap());
        return dr.documentID;
    } 

    Future<List<Shift>> queryShiftsByMonthAndYear(int month, int year) async {
        List<Shift> shifts = [];
        await databaseReference.collection(collectionId).getDocuments().then((QuerySnapshot snapshot) {
            snapshot.documents.forEach((f) {
                Shift shift = Shift.fromMap(f.data);
                DateTime date = DateTime.parse(shift.date);
                if (date.month == month && date.year == year)
                    shifts.add(shift);
            });
        });
        return shifts;
    }

    Future<Shift> queryShift(String id) async {
        DocumentSnapshot doc = await databaseReference.collection(collectionId).document(id).get();
        Shift shift = Shift.fromMap(doc.data);
        return shift;
    }

    Future<void> clear() async {
        databaseReference.collection(collectionId).getDocuments().then((snapshot) {
            for (DocumentSnapshot ds in snapshot.documents) {
                ds.reference.delete();
            }
        });
    }

    Future<void> update(Shift shift) async {
        await databaseReference.collection(collectionId).document(shift.id)
                .updateData(shift.toMap());
    }

    Future<double> getAllIncomeByDate(int month, int year) async {
        double income = 0;
        List<Shift> shifts = await queryShiftsByMonthAndYear(month, year);
        for (Shift shift in shifts) {
            income += shift.income;
        }
        return income;
    }
}
