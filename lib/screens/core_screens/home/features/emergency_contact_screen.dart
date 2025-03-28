import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ungal_kaavalan/providers/contact_provider.dart';
import 'package:ungal_kaavalan/providers/provider.dart';

class EmergencyContactScreen extends ConsumerWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(emergencyContactProvider);
    final uid = ref.watch(uidProvider); // Fetch UID from provider

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => context.go('/landing'),
            icon: Icon(Icons.arrow_back)),
        title: Text(
          'Emergency Contacts',
        ),
      ),
      body: contacts.isEmpty
          ? Center(child: Text("No emergency contacts added."))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.person, color: Colors.blue),
                  title: Text(contacts[index]['name']!),
                  subtitle: Text(contacts[index]['phone']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          _showAddOrEditContactDialog(
                            context,
                            ref,
                            uid!,
                            isEditing: true,
                            index: index,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          ref
                              .read(emergencyContactProvider.notifier)
                              .removeContact(index);

                          final uid = ref.read(
                              uidProvider); // Read the UID stored in the provider

                          if (uid != null) {
                            await ref
                                .read(emergencyContactProvider.notifier)
                                .saveEmergencyContacts(uid);
                          }
                          await ref
                              .read(emergencyContactProvider.notifier)
                              .saveContactsToPrefs();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddOrEditContactDialog(context, ref, uid!, isEditing: false);
        },
      ),
    );
  }

  void _showAddOrEditContactDialog(
    BuildContext context,
    WidgetRef ref,
    String uid, {
    required bool isEditing,
    int? index,
  }) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    if (isEditing && index != null) {
      final contact = ref.read(emergencyContactProvider)[index];
      nameController.text = contact['name']!;
      phoneController.text = contact['phone']!;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'Edit Emergency Contact' : 'Add Emergency Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String name = nameController.text.trim();
                  String phone = phoneController.text.trim();

                  if (name.isNotEmpty && phone.isNotEmpty) {
                    if (isEditing && index != null) {
                      ref
                          .read(emergencyContactProvider.notifier)
                          .editContact(index, name, phone);
                    } else {
                      ref.read(emergencyContactProvider.notifier).addContact(
                            name,
                            phone,
                          );
                    }

                    await ref
                        .read(emergencyContactProvider.notifier)
                        .saveEmergencyContacts(uid);
                    await ref
                        .read(emergencyContactProvider.notifier)
                        .saveContactsToPrefs();

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context); // Close bottom sheet
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter valid details')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Update Contact' : 'Save Contact'),
              ),
            ],
          ),
        );
      },
    );
  }
}
