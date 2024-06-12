import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/models/client.dart';
import 'package:easy_pos_r5/pages/operations/client_ops.dart';
import 'package:easy_pos_r5/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<ClientData>? Clients;
  @override
  void initState() {
    getClients();
    super.initState();
  }

  void getClients() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('clients');

      if (data.isNotEmpty) {
        Clients = [];
        for (var item in data) {
          Clients!.add(ClientData.fromJson(item));
        }
      } else {
        Clients = [];
      }
    } catch (e) {
      print('Error In get client $e');
      Clients = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => ClientsOpsPage()));
                if (result ?? false) {
                  getClients();
                }
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                var result = await sqlHelper.db!.rawQuery("""
        SELECT * FROM clients
        WHERE name LIKE '%$value%' OR email LIKE '%$value%';
          """);

                print('values:${result}');
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                labelText: 'Search',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: AppTable(
                    minWidth: 1100,
                    columns: const [
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('email')),
                      DataColumn(label: Text('phone')),
                      DataColumn(label: Text('address')),
                      DataColumn(label: Center(child: Text('Actions'))),
                    ],
                    source: ClientsTableSource(
                      ClientsEx: Clients,
                      onUpdate: (ClientData) async {
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => ClientsOpsPage(
                                      clientData: ClientData,
                                    )));
                        if (result ?? false) {
                          getClients();
                        }
                      },
                      onDelete: (ClientData) {
                        onDeleteRow(ClientData.id!);
                      },
                    ))),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Client'),
              content:
                  const Text('Are you sure you want to delete this Client?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          'clients',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getClients();
        }
      }
    } catch (e) {
      print('Error In delete client $e');
    }
  }
}

class ClientsTableSource extends DataTableSource {
  List<ClientData>? ClientsEx;

  void Function(ClientData) onUpdate;
  void Function(ClientData) onDelete;
  ClientsTableSource(
      {required this.ClientsEx,
      required this.onUpdate,
      required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${ClientsEx?[index].id}')),
      DataCell(Text('${ClientsEx?[index].name}')),
      DataCell(Text('${ClientsEx?[index].email}')),
      DataCell(Text('${ClientsEx?[index].phone}')),
      DataCell(Text('${ClientsEx?[index].address}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                onUpdate(ClientsEx![index]);
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                onDelete(ClientsEx![index]);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => ClientsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
