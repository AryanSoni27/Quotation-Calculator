import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper instance = DBHelper._();

  //Table for quotation item
  static final String QUOTATION_TABLE = 'quotation';
  static final String COLUMN_SNO = 's_no';
  static final String COLUMN_ITEM_NAME = 'item_name';
  static final String COLUMN_UNIT = 'unit';
  static final String COLUMN_SHAPE = 'shape';
  static final String COLUMN_LENGTH = 'length';
  static final String COLUMN_WIDTH = 'width';
  static final String COLUMN_HEIGHT = 'height';
  static final String COLUMN_FOOT = 'foot';
  static final String COLUMN_NA = 'na';
  static final String COLUMN_SQUARE_FEET = 'square_feet';
  static final String COLUMN_QUANTITY = 'quantity';
  static final String COLUMN_RATE = 'rate';
  static final String COLUMN_TOTAL_COST = 'total_cost';


  Database? myDb;

  Future<Database> getDB() async {
    myDb ??= await openDB();
    return myDb!;

    // if (myDb != null) {
    //   return myDb!;
    // } else {
    //   myDb = await openDB();
    //   return myDb!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, 'quotation.db');

    return await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE $QUOTATION_TABLE "
              "($COLUMN_SNO INTEGER PRIMARY KEY AUTOINCREMENT,"
              "$COLUMN_ITEM_NAME TEXT,"
              "$COLUMN_UNIT TEXT,"
              "$COLUMN_SHAPE TEXT,"
              "$COLUMN_LENGTH DOUBLE,"
              "$COLUMN_WIDTH DOUBLE,"
              "$COLUMN_HEIGHT DOUBLE,"
              "$COLUMN_FOOT DOUBLE,"
              "$COLUMN_NA DOUBLE,"
              "$COLUMN_SQUARE_FEET DOUBLE,"
              "$COLUMN_QUANTITY INTEGER,"
              "$COLUMN_RATE DOUBLE,"
              "$COLUMN_TOTAL_COST DOUBLE )",
        );
      },
    );
  }


  //Queries for database
  //Insert a new quotation item
  Future<int> insertQuotationItem(Map<String, dynamic> row) async {
    Database db = await getDB();
    return await db.insert(QUOTATION_TABLE, row);
  }

  //Get all quotation items
  Future<List<Map<String, dynamic>>> getAllQuotationItems() async {
    Database db = await getDB();
    return await db.query(QUOTATION_TABLE);
  }

  //Read quotation item by id
  Future<Map<String, dynamic>?> getQuotationItemById(int id) async {
    Database db = await getDB();
    List<Map<String, dynamic>> result = await db.query(
      QUOTATION_TABLE,
      where: "$COLUMN_SNO = ?",
      whereArgs: [id],
    );

    return result.isNotEmpty ? result.first : null;
  }

  //Update a quotation item
  Future<int> updateQuotationItem(
      String oldItemName,
      String oldUnit,
      String oldShape,
      double oldLength,
      double oldWidth,
      double? oldHeight,
      double? oldFoot,
      double oldSquareFeet,
      int oldQuantity,
      double oldRate,
      double oldTotalCost,
      Map<String, dynamic> newValues,
      ) async {
    Database db = await getDB();

    return await db.update(
      QUOTATION_TABLE,
      newValues,
      where: "$COLUMN_ITEM_NAME = ? AND "
          "$COLUMN_UNIT = ? AND "
          "$COLUMN_SHAPE = ? AND "
          "$COLUMN_LENGTH = ? AND "
          "$COLUMN_WIDTH = ? "
          "${oldHeight != null ? "AND $COLUMN_HEIGHT = ?" : ""} "
          "${oldFoot != null ? "AND $COLUMN_FOOT = ?" : ""} ",
      whereArgs: [
        oldItemName,
        oldUnit,
        oldShape,
        oldLength,
        oldWidth,
        if (oldHeight != null) oldHeight,
        if (oldFoot != null) oldFoot,
      ],
    );
  }


  //Delete a quotation item
  Future<int> deleteQuotationItem(int id) async {
    Database db = await getDB();
    return await db.delete(
      QUOTATION_TABLE,
      where: "$COLUMN_SNO = ?",
      whereArgs: [id],
    );
  }

  //Delete all quotation items
  Future<int> deleteAllQuotationItems() async {
    Database db = await getDB();
    return await db.delete(QUOTATION_TABLE);
  }

  //Read quotation items by name
  Future<List<Map<String, dynamic>>> searchQuotationItems(String query) async {
    Database db = await getDB();
    return await db.query(
      QUOTATION_TABLE,
      where: "$COLUMN_ITEM_NAME LIKE ?",
      whereArgs: ['%$query%'],
    );
  }

  // // Calculate total cost of all quotation items
  // Future<double> calculateTotalCost() async {
  //   Database db = await getDB();
  //   List<Map<String, dynamic>> result = await db.rawQuery(
  //       "SELECT SUM($COLUMN_TOTAL_COST) as total FROM $QUOTATION_TABLE"
  //   );
  //
  //   return result.first["total"] ?? 0.0;
  // }

  //Close database
  Future<void> closeDatabase() async {
    if (myDb != null && myDb!.isOpen) {
      await myDb!.close();
      myDb = null;
    }
  }

  // Future<int> deleteAllQuotationItems() async {
  //   Database db = await getDB();
  //   return await db.delete(QUOTATION_TABLE); // Ensure correct table name
  // }
}
