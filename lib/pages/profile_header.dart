import 'package:flutter/material.dart';
import 'app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final String? profilePicUrl;

  const ProfileHeader({
    Key? key,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.profilePicUrl,
  }) : super(key: key);
  @override
  String get displayName {
    // 1. Ism va familiya mavjudligini tekshirish
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName!;
    }

    // 2. Agar ism/familiya bo'lmasa, username'ni tekshirish
    final isDefaultUsername = username != null && username!.length == 8 && username!.contains(RegExp(r'[0-9]'));

    if (username != null && username!.isNotEmpty && !isDefaultUsername) {
      return username!; // Agar ism kiritilgan bo'lsa, uni ko'rsatish
    }
    return 'Foydalanuvchi';
  }
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.accentGreen,
          AppColors.primaryGreenDark,
        ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    profilePicUrl ?? 'https://via.placeholder.com/150', // Agar rasm bo'lmasa, vaqtinchalik rasm
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const CircleAvatar(
                          backgroundColor: AppColors.lightGreen,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: AppColors.primaryGreen,
                          ));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Profile Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email ?? '',
                    style: const TextStyle(fontSize: 13, color: AppColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}