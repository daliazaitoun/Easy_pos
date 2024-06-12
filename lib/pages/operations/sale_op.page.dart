import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/models/client.dart';
import 'package:easy_pos_r5/models/order.dart';
import 'package:easy_pos_r5/models/order_item.dart';
import 'package:easy_pos_r5/models/products.dart';
import 'package:easy_pos_r5/widgets/app_elevated_button.dart';
import 'package:easy_pos_r5/widgets/app_text_form_field.dart';
import 'package:easy_pos_r5/widgets/clients_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SaleOpsPage extends StatefulWidget {
  final Order? order;
  final ClientData? client;
  const SaleOpsPage({this.order, this.client, super.key});

  @override
  State<SaleOpsPage> createState() => _SaleOpsPageState();
}

class _SaleOpsPageState extends State<SaleOpsPage> {
  String? orderLabel;
  String? date;
  List<Product>? products;
  List<OrderItem> selectedOrderItem = [];
  int? selectedClientId;
  var formKey = GlobalKey<FormState>();
  TextEditingController? discountController;

  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() {
    orderLabel = widget.order == null
        ? '#OR${DateTime.now().millisecondsSinceEpoch}'
        : widget.order?.id.toString();
    getProducts();
    selectedClientId = widget.client?.id;

    discountController =
        TextEditingController(text: '${widget.order?.discount ?? ""}');
    setState(() {});
  }

  @override
  void dispose() {
    discountController?.dispose();
    super.dispose();
  }

  String? _validatePercentage(String? value) {
    final n = num.tryParse(value!);
    if (n == null) {
      return 'Please enter a valid number';
    }
    if (n < 0 || n > 100) {
      return 'Percentage must be between 0 and 100';
    }
    return null;
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select P.* ,C.name as categoryName,C.description as categoryDesc 
      from products P
      inner join categories C
      where P.categoryId = C.id
      """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products!.add(Product.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      print('Error In get data $e');
      products = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Add New Sale' : 'Update Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Label : $orderLabel',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ClientsDropDown(
                          selectedValue: selectedClientId,
                          onChanged: (clientId) {
                            setState(() {
                              selectedClientId = clientId;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  onAddProductClicked();
                                },
                                icon: Icon(Icons.add)),
                            Text(
                              'Add Products',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Items',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        for (var orderItem in selectedOrderItem)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading:
                                  Image.network(orderItem.product?.image ?? ''),
                              title: Text(
                                  '${orderItem.product?.name ?? ''},${orderItem.productCount}X'),
                              trailing: Text(
                                  '${(orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0)}'),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextFormField(
                                  controller: discountController!,
                                  label: 'Discount',
                                  suffixText: '%',
                                  validator: (value) {
                                    return _validatePercentage(value);
                                  },
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: AppElevatedButton(
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    label: "Apply Discount"),
                              )
                            ],
                          ),
                        ),
                        Text(
                          '  Total Price : $calculateTotalPrice',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '  Discount :  ${discountController!.text}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '  Net Price : $netPrice ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: AppElevatedButton(
                      onPressed: selectedOrderItem.isEmpty
                          ? null
                          : () async {
                              await onSetOrder();
                            },
                      label: 'Add Order'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSetOrder() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.order != null) {
          await sqlHelper.db!.update(
              'orders',
              {
                'clientId': selectedClientId,
                'totalPrice': calculateTotalPrice,
                'date': DateTime.now().toIso8601String(),
                'discount': discountController?.text,
              },
              where: 'id =?',
              whereArgs: [widget.order?.id]);
          var batch = sqlHelper.db!.batch();
          for (var orderItem in selectedOrderItem) {
            batch.update('orderProductItems', {
              'productId': orderItem.productId,
              'productCount': orderItem.productCount ?? 0,
            });
          }
        } else {
          var orderId = await sqlHelper.db!.insert('orders', {
            'label': orderLabel,
            'totalPrice': calculateTotalPrice,
            'discount': discountController?.text,
            'date': DateTime.now().toIso8601String(),
            'clientId': selectedClientId
          });

          var batch = sqlHelper.db!.batch();
          for (var orderItem in selectedOrderItem) {
            batch.insert('orderProductItems', {
              'orderId': orderId,
              'productId': orderItem.productId,
              'productCount': orderItem.productCount ?? 0,
            });
          }

          await batch.commit();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Order Set Successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Create Order : $e')));
    }
  }

  double get calculateTotalPrice {
    double total = 0;

    for (var orderItem in selectedOrderItem) {
      total = total +
          ((orderItem.productCount ?? 0) * (orderItem.product?.price ?? 0));
    }

    return total;
  }

  double get netPrice {
    double total = calculateTotalPrice;
    if (discountController!.text.isNotEmpty) {
      total = total - (total * double.parse(discountController!.text) / 100);
    }

    return total;
  }

  void onAddProductClicked() async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateEx) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: (products?.isEmpty ?? false)
                    ? Center(
                        child: Text('No Data Found'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Products',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var product in products!)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListTile(
                                        leading: Image.network(
                                            product.image ?? 'No Image'),
                                        title: Text(product.name ?? 'No Name'),
                                        subtitle: getOrderItem(product.id!) ==
                                                null
                                            ? null
                                            : Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: getOrderItem(
                                                                      product
                                                                          .id!) !=
                                                                  null &&
                                                              getOrderItem(product
                                                                          .id!)
                                                                      ?.productCount ==
                                                                  1
                                                          ? null
                                                          : () {
                                                              var orderItem =
                                                                  getOrderItem(
                                                                      product
                                                                          .id!);

                                                              orderItem
                                                                      ?.productCount =
                                                                  (orderItem.productCount ??
                                                                          0) -
                                                                      1;
                                                              setStateEx(() {});
                                                            },
                                                      icon: Icon(Icons.remove)),
                                                  Text(
                                                      getOrderItem(product.id!)!
                                                          .productCount
                                                          .toString()),
                                                  IconButton(
                                                      onPressed: () {
                                                        var orderItem =
                                                            getOrderItem(
                                                                product.id!);

                                                        if ((orderItem
                                                                    ?.productCount ??
                                                                0) <
                                                            (product.stock ??
                                                                0)) {
                                                          orderItem
                                                                  ?.productCount =
                                                              (orderItem.productCount ??
                                                                      0) +
                                                                  1;
                                                        }

                                                        setStateEx(() {});
                                                      },
                                                      icon: Icon(Icons.add)),
                                                ],
                                              ),
                                        trailing:
                                            getOrderItem(product.id!) == null
                                                ? IconButton(
                                                    onPressed: () {
                                                      onAddItem(product);
                                                      setStateEx(() {});
                                                    },
                                                    icon: Icon(Icons.add))
                                                : IconButton(
                                                    onPressed: () {
                                                      onDeleteItem(product.id!);
                                                      setStateEx(() {});
                                                    },
                                                    icon: Icon(Icons.delete))),
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AppElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              label: 'Back')
                        ],
                      ),
              ),
            );
          });
        });

    setState(() {});
  }

  OrderItem? getOrderItem(int productId) {
    for (var item in selectedOrderItem) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }

  void onAddItem(Product product) {
    selectedOrderItem.add(
        OrderItem(productId: product.id, productCount: 1, product: product));
  }

  void onDeleteItem(int productId) {
    for (var i = 0; i < (selectedOrderItem.length); i++) {
      if (selectedOrderItem[i].productId == productId) {
        selectedOrderItem.removeAt(i);
        break;
      }
    }
  }
}
