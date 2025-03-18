class UserModel {
  String uid;
  String name;
  String phone;
  String gender;
  String age;
  String address;
  String aadhar;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    required this.address,
    required this.aadhar,
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
    };
  }
}
