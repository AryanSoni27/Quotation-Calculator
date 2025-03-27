import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/quotation_item.dart';
import '../models/quotation_screen.dart';

class DBHelperQuotation {
  static final DBHelperQuotation instance = DBHelperQuotation._init();
  static Database? _database;

  DBHelperQuotation._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quotations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increment version number
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Add onUpgrade method
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Quotation items table
    await db.execute('''
      CREATE TABLE quotation_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemName TEXT NOT NULL,
        unit TEXT NOT NULL,
        shape TEXT NOT NULL,
        length REAL NOT NULL,
        width REAL NOT NULL,
        height REAL,
        foot REAL, // Ensure this column is in the initial creation
        squareFeet REAL NOT NULL,
        quantity INTEGER NOT NULL,
        rate REAL NOT NULL,
        totalCost REAL NOT NULL
      )
    ''');

    // Quotations table
    await db.execute('''
      CREATE TABLE quotations (
        id TEXT PRIMARY KEY,
        customerName TEXT NOT NULL,
        date TEXT NOT NULL,
        projectName TEXT NOT NULL,
        mobileNumber TEXT NOT NULL,
        totalAmount REAL NOT NULL
      )
    ''');

    // Quotation items relationship table
    await db.execute('''
      CREATE TABLE quotation_item_relations (
        quotationId TEXT NOT NULL,
        itemId INTEGER NOT NULL,
        PRIMARY KEY (quotationId, itemId),
        FOREIGN KEY (quotationId) REFERENCES quotations (id) ON DELETE CASCADE,
        FOREIGN KEY (itemId) REFERENCES quotation_items (id) ON DELETE CASCADE
      )
    ''');
  }

  // New method to handle database upgrades
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Add the foot column if it doesn't exist
      await db.execute('ALTER TABLE quotation_items ADD COLUMN foot REAL');
    }
  }


  // Quotation Item Operations
  Future<int> insertQuotationItem(QuotationItem item) async {
    final db = await database;
    final Map<String, dynamic> itemMap = {
      'itemName': item.itemName,
      'unit': item.unit,
      'shape': item.shape,
      'length': item.length,
      'width': item.width,
      'height': item.height,
      'foot': item.foot,
      'squareFeet': item.squareFeet,
      'quantity': item.quantity,
      'rate': item.rate,
      'totalCost': item.totalCost,
    };

    return await db.insert('quotation_items', itemMap);
  }

  Future<List<QuotationItem>> getAllQuotationItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('quotation_items');

    return List.generate(maps.length, (i) {
      return QuotationItem(
        id: maps[i]['id'],
        itemName: maps[i]['itemName'],
        unit: maps[i]['unit'],
        shape: maps[i]['shape'],
        length: maps[i]['length'],
        width: maps[i]['width'],
        height: maps[i]['height'],
        foot: maps[i]['foot'],
        squareFeet: maps[i]['squareFeet'],
        quantity: maps[i]['quantity'],
        rate: maps[i]['rate'],
        totalCost: maps[i]['totalCost'],
      );
    });
  }

  Future<int> updateQuotationItem(int id, QuotationItem item) async {
    final db = await database;
    final Map<String, dynamic> itemMap = {
      'itemName': item.itemName,
      'unit': item.unit,
      'shape': item.shape,
      'length': item.length,
      'width': item.width,
      'height': item.height,
      'foot' : item.foot,
      'squareFeet': item.squareFeet,
      'quantity': item.quantity,
      'rate': item.rate,
      'totalCost': item.totalCost,
    };

    return await db.update(
      'quotation_items',
      itemMap,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteQuotationItem(int id) async {
    final db = await database;
    return await db.delete(
      'quotation_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllQuotationItems() async {
    final db = await database;
    await db.delete('quotation_items');
  }

  // Quotation Operations
  Future<String> saveQuotation(Quotation quotation) async {
    final db = await database;

    await db.transaction((txn) async {
      // Insert the quotation
      await txn.insert(
        'quotations',
        quotation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert all quotation items
      for (var item in quotation.items) {
        // Save the item first
        int itemId = await txn.insert('quotation_items', {
          'itemName': item.itemName,
          'unit': item.unit,
          'shape': item.shape,
          'length': item.length,
          'width': item.width,
          'height': item.height,
          'foot': item.foot,
          'squareFeet': item.squareFeet,
          'quantity': item.quantity,
          'rate': item.rate,
          'totalCost': item.totalCost,
        });

        // Create the relationship
        await txn.insert('quotation_item_relations', {
          'quotationId': quotation.id,
          'itemId': itemId,
        });
      }
    });

    return quotation.id;
  }

  Future<List<Quotation>> getAllQuotations() async {
    final db = await database;

    // Get all quotations
    final List<Map<String, dynamic>> quotationsMaps = await db.query('quotations');
    List<Quotation> quotations = [];

    for (var quotationMap in quotationsMaps) {
      String quotationId = quotationMap['id'];

      // Get all item IDs for this quotation
      final List<Map<String, dynamic>> relationMaps = await db.query(
        'quotation_item_relations',
        where: 'quotationId = ?',
        whereArgs: [quotationId],
      );

      List<QuotationItem> items = [];

      // Get each item by its ID
      for (var relationMap in relationMaps) {
        int itemId = relationMap['itemId'];

        final List<Map<String, dynamic>> itemMaps = await db.query(
          'quotation_items',
          where: 'id = ?',
          whereArgs: [itemId],
        );

        if (itemMaps.isNotEmpty) {
          var itemMap = itemMaps.first;
          items.add(QuotationItem(
            id: itemMap['id'],
            itemName: itemMap['itemName'],
            unit: itemMap['unit'],
            shape: itemMap['shape'],
            length: itemMap['length'],
            width: itemMap['width'],
            height: itemMap['height'],
            squareFeet: itemMap['squareFeet'],
            quantity: itemMap['quantity'],
            rate: itemMap['rate'],
            totalCost: itemMap['totalCost'],
            foot: itemMap['foot'],
          ));
        }
      }

      quotations.add(Quotation(
        id: quotationMap['id'],
        customerName: quotationMap['customerName'],
        date: quotationMap['date'],
        projectName: quotationMap['projectName'],
        mobileNumber: quotationMap['mobileNumber'],
        items: items,
        totalAmount: quotationMap['totalAmount'],
      ));
    }

    return quotations;
  }

  Future<Quotation?> getQuotationById(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> quotationMaps = await db.query(
      'quotations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (quotationMaps.isEmpty) {
      return null;
    }

    // Get all item IDs for this quotation
    final List<Map<String, dynamic>> relationMaps = await db.query(
      'quotation_item_relations',
      where: 'quotationId = ?',
      whereArgs: [id],
    );

    List<QuotationItem> items = [];

    // Get each item by its ID
    for (var relationMap in relationMaps) {
      int itemId = relationMap['itemId'];

      final List<Map<String, dynamic>> itemMaps = await db.query(
        'quotation_items',
        where: 'id = ?',
        whereArgs: [itemId],
      );

      if (itemMaps.isNotEmpty) {
        var itemMap = itemMaps.first;
        items.add(QuotationItem(
          id: itemMap['id'],
          itemName: itemMap['itemName'],
          unit: itemMap['unit'],
          shape: itemMap['shape'],
          length: itemMap['length'],
          width: itemMap['width'],
          height: itemMap['height'],
          squareFeet: itemMap['squareFeet'],
          quantity: itemMap['quantity'],
          rate: itemMap['rate'],
          totalCost: itemMap['totalCost'],
          foot: itemMap['foot'],
        ));
      }
    }

    return Quotation(
      id: quotationMaps.first['id'],
      customerName: quotationMaps.first['customerName'],
      date: quotationMaps.first['date'],
      projectName: quotationMaps.first['projectName'],
      mobileNumber: quotationMaps.first['mobileNumber'],
      items: items,
      totalAmount: quotationMaps.first['totalAmount'],
    );
  }

  Future<int> deleteQuotation(String id) async {
    final db = await database;

    // Using a transaction to ensure both operations complete or fail together
    return await db.transaction((txn) async {
      // First delete from the relation table
      await txn.delete(
        'quotation_item_relations',
        where: 'quotationId = ?',
        whereArgs: [id],
      );

      // Then delete the quotation
      return await txn.delete(
        'quotations',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}