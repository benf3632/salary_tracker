import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

final String coulmnId = '_id';
final String coulmnStartTime = 'start_time';
final String coulmnEndTime = 'end_time';
final String coulmnDate = 'date';
final String coulmnIncome = 'income';
final String tableShifts = 'shifts';

class Shift {

    int id;
    int startTime;
    int endTime;
    var date;
    double income;
    
    Shift();

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
    static final _databaseName = 'shifts.db';
    static final _databaseVersion = 1;

    DatabaseHelper._privateConstructor();
    static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

    static Database _database;
    Future<Database> get database async {
        if (_database != null) return _database;
        _database = await _initDatabase();
        return _database;
    }

    _initDatabase() async {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        String path = join(documentsDirectory.path, _databaseName);
        return await  openDatabase(path,
            version: _databaseVersion,
            onCreate: _onCreate,
        );
    }

    Future _onCreate(Database db, int version) async {
        await db.execute('''
                CREATE TABLE  $tableShifts (
                   $coulmnId INTEGER PRIMARY KEY,
                   $coulmnStartTime INTEGER NOT NULL,
                   $coulmnEndTime INTEGER,
                   $coulmnIncome INTEGER,
                   $coulmnDate TEXT NOT NULL,
                )
                ''');
    }

    Future<int> insert(Shift shift) async {
        Database db = await database;
        int id = await db.insert(tableShifts, shift.toMap());
        return id;
    }

    Future<Shift> queryShift(int id) async {
        Database db = await database;
        List<Map> maps = await db.query(tableShifts,
            columns: [coulmnId, coulmnStartTime, coulmnEndTime, coulmnIncome, coulmnDate],
            where: '$coulmnId = ?',
            whereArgs: [id]
        );
        if (maps.length > 0) return Shift.fromMap(maps.first);
        return null;
    }

    Future<List<Shift>> queryShiftsByMonthAndYear(int month, int year) async {
        Database db = await database;
        List<Shift> shifts = [];
        List<Map> maps = await db.query(tableShifts,
            columns: [coulmnId, coulmnStartTime, coulmnEndTime, coulmnIncome, coulmnDate],
            where: 'strftime(\'%m%y\', $coulmnDate) = \'??\'',
            whereArgs: [month.toString().padLeft(2, '0'), year],

        );
        for(Map map in maps) {
            shifts.add(Shift.fromMap(map));
        }
        return shifts;
    }


}
