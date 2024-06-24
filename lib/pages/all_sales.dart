import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/models/order.dart';
import 'package:easy_pos_r5/pages/operations/sale_op.page.dart';
import 'package:easy_pos_r5/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllSales extends StatefulWidget {
  const AllSales({super.key});

  @override
  State<AllSales> createState() => _AllSalesState();
}

class _AllSalesState extends State<AllSales> {
  List<Order>? orders;
  bool sortValue = true;
  @override
  void initState() {
    getOrders();
    super.initState();
  }

  void getOrders() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select O.* ,C.name as clientName,C.phone as clientPhone,C.address as clientAddress
      from orders O
      inner join clients C
      where O.clientId = C.id
      """);

      if (data.isNotEmpty) {
        orders = [];
        for (var item in data) {
          orders!.add(Order.fromJson(item));
        }
      } else {
        orders = [];
      }
    } catch (e) {
      print('Error In get data $e');
      orders = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Sales'), actions: [
        IconButton(
          onPressed: () async {
            //1st option
            var sqlHelper = GetIt.I.get<SqlHelper>();
            var data = await sqlHelper.db!.rawQuery("""
                   select totalPrice
                    from orders
                    where totalPrice > 200;
                """);
            print(data);
            //2nd option
            Iterable<Order> filteredOrders =
                orders!.where((order) => order.clientName!.contains("ahmed"));
            filteredOrders.forEach((order) => print(order.clientName));

            setState(() {});
          },
          icon: Icon(Icons.filter_alt),
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.db!.rawQuery("""
        SELECT * FROM orders
        WHERE label LIKE '%$value%';
         WHERE clientName LIKE '%$value%';

          """);
                setState(() {});
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
                    sortColumnIndex: 2,
                    sortAscending: sortValue,
                    minWidth: 1100,
                    columns: [
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Label')),
                      DataColumn(
                          numeric: true,
                          label: Text('Total Price'),
                          onSort: (index, isAscending) {
                            sortValue = isAscending;
                            if (sortValue == false) {
                              orders!.sort((a, b) =>
                                  a.totalPrice!.compareTo(b.totalPrice!));
                            } else {
                              orders!.sort((a, b) =>
                                  b.totalPrice!.compareTo(a.totalPrice!));
                            }
                            setState(() {});
                          }),
                      DataColumn(label: Text('Discount')),
                      DataColumn(label: Text('Client Name')),
                      DataColumn(label: Text('Client phone')),
                      DataColumn(label: Text('Client Address')),
                      DataColumn(label: Center(child: Text('Actions'))),
                    ],
                    source: OrderDataSource(
                      ordersEx: orders,
                      onDelete: (order) {
                        onDeleteRow(order.id!);
                      },
                      onShow: (order) async {
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => SaleOpsPage(
                                      order: order,
                                    )));
                        if (result ?? false) {
                          getOrders();
                        }
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
              title: const Text('Delete Order'),
              content:
                  const Text('Are you sure you want to delete this order?'),
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
          'orders',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getOrders();
        }
      }
    } catch (e) {
      print('Error In delete data $e');
    }
  }
}



class OrderDataSource extends DataTableSource {
  List<Order>? ordersEx;

  void Function(Order) onShow;
  void Function(Order) onDelete;
  OrderDataSource(
      {required this.ordersEx, required this.onShow, required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${ordersEx?[index].id}')),
      DataCell(Text('${ordersEx?[index].label}')),
      DataCell(Text('${ordersEx?[index].totalPrice}')),
      DataCell(Text('${ordersEx![index].discount! / 100}')),
      DataCell(Text('${ordersEx?[index].clientName}')),
      DataCell(Text('${ordersEx?[index].clientPhone}')),
      DataCell(Text('${ordersEx?[index].clientAddress}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                onShow(ordersEx![index]);
              },
              icon: const Icon(Icons.visibility)),
          IconButton(
              onPressed: () {
                onDelete(ordersEx![index]);
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
  int get rowCount => ordersEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
