import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Backup extends StatefulWidget {
  const Backup({super.key});

  @override
  State<Backup> createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Backup")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppElevatedButton(
              onPressed: () async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.backupdb();
              },
              label: "Backup"),
              SizedBox(height: 10,),
          AppElevatedButton(onPressed:() async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper..getdbPath();
              }, label: "Path"),
             SizedBox(
            height: 10,
          ),
          AppElevatedButton(onPressed: () async {
             var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.restoreDB();
          }, label: "Restore"),
             SizedBox(
            height: 10,
          ),
          AppElevatedButton(
              onPressed: () async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.deleteDB();
              },
              label: "Delete"),
        ],
      ),
    );
  }
}
