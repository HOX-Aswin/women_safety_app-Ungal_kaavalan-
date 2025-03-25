import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **🛡 Emergency Contact Provider**
final emergencyContactProvider = StateNotifierProvider<EmergencyContactNotifier, List<Map<String, String>>>(
  (ref) => EmergencyContactNotifier(),
);

class EmergencyContactNotifier extends StateNotifier<List<Map<String, String>>> {
  EmergencyContactNotifier() : super([]) {
    loadContactsFromPrefs(); // Load existing contacts from local storage
  }

  /// **📌 Load contacts from SharedPreferences**
  Future<void> loadContactsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList('emergencyContacts');

      if (contactsJson != null) {
        state = contactsJson.map((contact) => Map<String, String>.from(jsonDecode(contact))).toList();
        print("✅ Loaded contacts from SharedPreferences: $state");
      } else {
        print("⚠️ No contacts found in SharedPreferences.");
      }
    } catch (e) {
      print("❌ Error loading contacts from SharedPreferences: $e");
    }
  }

  /// **📌 Save contacts to SharedPreferences**
  Future<void> saveContactsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = state.map((contact) => jsonEncode(contact)).toList();
      await prefs.setStringList('emergencyContacts', contactsJson);
      print("✅ Saved contacts to SharedPreferences: $contactsJson");
    } catch (e) {
      print("❌ Error saving contacts to SharedPreferences: $e");
    }
  }

  /// **📌 Set contacts (when syncing from Firestore)**
  Future<void> setContacts(List<Map<String, String>> contacts) async {
    print("🔄 setContacts called with: $contacts");
    state = contacts;
    await saveContactsToPrefs();
    print("✅ Contacts saved in provider: $state");
  }

  /// **📌 Add a new contact**
  Future<void> addContact(String name, String phone) async {
    state = [...state, {'name': name, 'phone': phone}];
    await saveContactsToPrefs();
    print("✅ Contact added: $name, $phone");
  }

  /// **📌 Edit an existing contact**
  Future<void> editContact(int index, String newName, String newPhone) async {
    if (index < 0 || index >= state.length) {
      print("❌ Error: Invalid contact index.");
      return;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) {'name': newName, 'phone': newPhone} else state[i],
    ];
    await saveContactsToPrefs();
    print("✅ Contact updated at index $index: $newName, $newPhone");
  }

  /// **📌 Remove a contact**
  Future<void> removeContact(int index) async {
    if (index < 0 || index >= state.length) {
      print("❌ Error: Invalid contact index.");
      return;
    }

    state = [...state]..removeAt(index);
    await saveContactsToPrefs();
    print("✅ Contact removed at index: $index");
  }

  /// **📌 Fetch contacts from Firestore**
  Future<List<Map<String, String>>> fetchEmergencyContacts(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null && doc.data()!.containsKey('emergencyContacts')) {
        List<dynamic> contactsList = doc.data()!['emergencyContacts'];
        print("🔥 Raw contacts from Firestore: $contactsList");

        return contactsList.map((contact) => Map<String, String>.from(contact)).toList();
      }

      print("⚠️ No emergency contacts found in Firestore for UID: $uid");
      return [];
    } catch (e) {
      print("❌ Error fetching emergency contacts: $e");
      return [];
    }
  }

  /// **📌 Sync contacts from Firestore**
  Future<void> syncEmergencyContacts(String uid) async {
    try {
      List<Map<String, String>> contacts = await fetchEmergencyContacts(uid);
      await setContacts(contacts);
    } catch (e) {
      print("❌ Error syncing emergency contacts: $e");
    }
  }

  /// **📌 Save contacts to Firestore**
  Future<void> saveEmergencyContacts(String uid) async {
    try {
      print("💾 Saving emergency contacts for UID: $uid");
      print("Contacts: $state");

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emergencyContacts': state,
      });

      print("✅ Emergency contacts successfully saved to Firestore!");
    } catch (e) {
      print("❌ Error saving emergency contacts to Firestore: $e");
    }
  }
}
