class RegisterModel {
  String email;
  String phone;
  String address;

  RegisterModel({
    required this.email,
    required this.phone,
    required this.address,
  });

Map<String, dynamic> toJson() {
    return {
      "email": email,
      "phone": phone,
      "address": address,
    };
  }
}