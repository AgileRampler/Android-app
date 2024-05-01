import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressBook extends StatefulWidget {
  const AddressBook({Key? key}) : super(key: key);

  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  late SharedPreferences prefs;
  List<String> addresses = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    addresses = prefs.getStringList('addresses') ?? [];
    print(addresses);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Book'),
      ),
      body: ListView(
        children: [
          for (String address in addresses)
            ListTile(
              title: Text(address, style: const TextStyle(color: Colors.white)),
              trailing: Wrap(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Extract the address from the details string
                      final parts = address.split(' - ');
                      final addressOnly = parts.length > 1 ? parts[1] : address;
                      Clipboard.setData(ClipboardData(text: addressOnly));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied to clipboard'),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      addresses.remove(address);
                      prefs.setStringList('addresses', addresses);
                      setState(() {});
                    },
                  ),
                ],
              ),

            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final address = await showDialog<String>(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('Add Address'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Govind P Kumar',
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: '0x...',
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      String details =
                          nameController.text + ' - ' + addressController.text;
                      addressController.text = '';
                      nameController.text = '';

                      if (details.isNotEmpty) {
                        addresses.add(details);
                        prefs.setStringList('addresses', addresses);
                        print(addresses);
                        setState(() {});
                      }
                      Navigator.pop(context, controller.text);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
