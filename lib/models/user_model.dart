class UserModel {
  String uid;
  String name;
  String phone;
  String gender;
  String age;
  String address;
  String aadhar;
  List<Map<String, String>> emergencyContacts; // List of contacts

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    required this.address,
    required this.aadhar,
    required this.emergencyContacts,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      phone: data['phone'],
      gender: data['gender'],
      age: data['age'],
      address: data['address'],
      aadhar: data['aadhar'],
      emergencyContacts: List<Map<String, String>>.from(
        (data['emergencyContacts'] ?? []).map((e) => Map<String, String>.from(e)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'gender': gender,
      'age': age,
      'address': address,
      'aadhar': aadhar,
      'emergencyContacts': emergencyContacts,
    };
  }
}
