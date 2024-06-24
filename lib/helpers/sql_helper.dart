import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper {
  Database? db;

  Future<void> init() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        db = await factory.openDatabase('pos.db');
      } else {
        db = await openDatabase(
          'pos.db',
          version: 1,
          onCreate: (db, version) {
            print('database created successfully');
          },
        );
      }
    } catch (e) {
      print('Error in creating database: $e');
    }
  }

  Future<void> registerForeignKeys() async {
    await db!.rawQuery("PRAGMA foreign_keys = ON");
    var result = await db!.rawQuery("PRAGMA foreign_keys");

    print('foreign keys result : $result');
  }

  Future<bool> createTables() async {
    try {
      await registerForeignKeys();
      var batch = db!.batch();
      batch.execute("""
        Create table if not exists categories(
          id integer primary key,
          name text not null,
          description text not null
          ) 
          """);

      batch.execute("""
        Create table if not exists products(
          id integer primary key,
          name text not null,
          description text not null,
          price double not null,
          stock integer not null,
          isAvaliable boolean not null,
          image text,
          categoryId integer not null,
          foreign key(categoryId) references categories(id)
          on delete restrict
          ) 
          """);

      batch.execute("""
        Create table if not exists clients(
          id integer primary key,
          name text not null,
          email text,
          phone text,
          address text
          ) 
          """);
      batch.execute("""
        Create table if not exists orders(
          id integer primary key,
          label text,
          totalPrice real,
          discount real,
          date TEXT,
          clientId integer not null,
          foreign key(clientId) references clients(id)
          on delete restrict
          ) 
          """);
      batch.execute("""
        Create table if not exists orderProductItems(
         orderId integer,
         productCount integer,
         productId integer,
          foreign key(productId) references products(id)
          on delete restrict
          ) 
          """);
      batch.execute("""
       CREATE TABLE if not exists exchange_rates (
        id INTEGER PRIMARY KEY,
        from_currency TEXT,
        to_currency TEXT
       
        
      )
          """);

      var result = await batch.commit();
      print('resuts $result');
      return true;
    } catch (e) {
      print('Error in creating table: $e');
      return false;
    }
  }

  Future<double> getTotalSalesForToday() async {
    GetIt.I.get<SqlHelper>();
    String today = DateTime.now().toIso8601String().split('T').first;
    List<Map<String, dynamic>> result = await db!.rawQuery('''
      SELECT SUM(totalPrice) as total_sales FROM orders WHERE date LIKE '$today%'
    ''');
    double totalSales = result.first['total_sales'] ?? 0.0;
    return totalSales;
  }

  Future getdbPath() async {
    try {
      String dbb = await getDatabasesPath();
      print("pppppp>>> =============$dbb");
      Directory? exteralStoragePath = await getExternalStorageDirectory();
      print("eeeeeeee>>> ===========$exteralStoragePath");
    } catch (e) {
      print("==============$e");
    }
  }

  backupdb() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      File ourDBFlie =
          File("/data/user/0/com.example.easy_pos_r5/databases/pos.db");
      Directory? FolderPathDB = Directory("/storage/emulated/0/Android/data/com.example.easy_pos_r5/files");
      await FolderPathDB.create();
      await ourDBFlie.copy("/storage/emulated/0/Android/data/com.example.easy_pos_r5/files/pos.db");
      print("backup done");
    } catch (e) {
      print("==================================${e.toString()}");
    }
  }

  restoreDB() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      File saved = File("/storage/emulated/0/posDatabase/pos.db");
      await saved.copy("/storage/emulated/0/Android/data/com.example.easy_pos_r5/files/pos.db");
    } catch (e) {
      print("==================================${e.toString()}");
    }
  }

  deleteDB() async {
    try {
      db = null;
      deleteDatabase("/storage/emulated/0/Android/data/com.example.easy_pos_r5/files/pos.db");
    } catch (e) {
       print("==================================${e.toString()}");
    }
  }
}
