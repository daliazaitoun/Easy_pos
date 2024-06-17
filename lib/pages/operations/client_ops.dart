import 'package:easy_pos_r5/helpers/sql_helper.dart';
import 'package:easy_pos_r5/models/client.dart';
import 'package:easy_pos_r5/widgets/app_elevated_button.dart';
import 'package:easy_pos_r5/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class ClientsOpsPage extends StatefulWidget {
  final ClientData? clientData;

  const ClientsOpsPage({this.clientData, super.key});

  @override
  State<ClientsOpsPage> createState() => _ClientsOpsPageState();
}

class _ClientsOpsPageState extends State<ClientsOpsPage> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? phoneController;
  TextEditingController? addressController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.clientData?.name);
    emailController = TextEditingController(text: widget.clientData?.email);
    phoneController = TextEditingController(text: widget.clientData?.phone);
    addressController = TextEditingController(text: widget.clientData?.address);
    super.initState();
  }

  @override
  void dispose() {
    nameController!.dispose();
    emailController!.dispose();
    phoneController!.dispose();
    addressController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientData != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextFormField(
                    textInputAction: TextInputAction.next,
                    controller: nameController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    label: 'Name'),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                  keyboardType: TextInputType.emailAddress,
                    controller: emailController!,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'email is required';
                      }
                      return null;
                    },
                    label: 'Email'),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                keyboardType: TextInputType.number,
                  maxLength: 11,
                    textInputAction: TextInputAction.next,
                    controller: phoneController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'phone is required';
                      }
                      return null;
                    },
                    label: 'Phone'),
                const SizedBox(
                  height: 20,
                ),
                AppTextFormField(
                    textInputAction: TextInputAction.done,
                    controller: addressController!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'address is required';
                      }
                      return null;
                    },
                    label: 'Address'),
                const SizedBox(
                  height: 20,
                ),
                AppElevatedButton(
                  label: 'Submit',
                  onPressed: () async {
                    await onSubmit();
                  },
                ),
              ],
            )),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.clientData != null) {
          // update logic
          await sqlHelper.db!.update(
              'clients',
              {
                'name': nameController?.text,
                'email': emailController?.text,
                'phone': phoneController?.text,
                'address': addressController?.text,
              },
              where: 'id =?',
              whereArgs: [widget.clientData?.id]);
        } else {
          await sqlHelper.db!.insert('clients', {
            'name': nameController?.text,
            'email': emailController?.text,
            'phone': phoneController?.text,
            'address': addressController?.text
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Client Saved Successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Create Client : $e')));
    }
  }
}
