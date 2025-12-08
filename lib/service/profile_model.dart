import 'dart:convert';

class Profile {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String? profile_pic;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? birthdate;
  final String address;

  Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    this.profile_pic,
    this.firstName,
    this.lastName,
    this.middleName,
    this.birthdate,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '', // Ikkala keyni ham tekshirish
      profile_pic: json['profile_pic'],
      address: json['address'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
      birthdate: json['birthdate'],
    );
  }
}

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));