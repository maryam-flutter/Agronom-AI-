import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'app_colors.dart';
import 'about_app_screen.dart'; 

import 'favorites_screen.dart';

import 'notifications_screen.dart';
import 'profile_header.dart';
import 'profile_menu_item.dart';
import 'support_screen.dart';
import '../registerProvider/profile_provider.dart';
import 'profile_page.dart';

import 'initial_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationOn = true; // default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: provider.userProfile == null
              ? (provider.errorMessage != null ? Center(child: Text(provider.errorMessage!)) : const Center(child: CircularProgressIndicator()))
              : _buildProfileView(context, provider),
        );
      },
    );
  }

  Widget _buildProfileView(BuildContext context, ProfileProvider provider) {
    final user = provider.userProfile;

    return Column(
      children: [
        // Gradient Header Section
        ProfileHeader(
          username: user?.username,
          email: user?.email,
          profilePicUrl: user?.profile_pic,
        ),

        // Menu Items List
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ProfileMenuItem(
                icon: Icons.account_circle_outlined,
                title: 'Ma\'lumotlarim',
                onTap: () {
                  if (provider.userProfile != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(profile: provider.userProfile!)));
                  }
                },
              ),
              const MenuDivider(),
              ProfileMenuItem(
                icon: Icons.favorite_border,
                title: 'Yoqtirganlarim',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())),
              ),
              const MenuDivider(),
              _buildMenuItemWithSwitch(
                icon: Icons.notifications_none_outlined,
                title: 'Bildirishnomalar',
                value: _isNotificationOn,
                onChanged: (val) {
                  setState(() {
                    _isNotificationOn = val;
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              const MenuDivider(),
              ProfileMenuItem(
                icon: Icons.groups_outlined,
                title: 'Ilova haqida',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen())),
              ),
              const MenuDivider(),
              ProfileMenuItem(
                icon: Icons.support_agent,
                title: 'Qo\'llab quvvatlash',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())),
              ),
              const MenuDivider(),
              ProfileMenuItem(
                icon: Icons.power_settings_new_outlined,
                title: 'Chiqish',
                onTap: () => _showLogoutDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemWithSwitch({
  required IconData icon,
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap, // 🔽 qatorni bosganda sahifaga o'tadi
    child: Material(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textBlack),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textBlack),
              ),
            ),
            Switch(
              value: value,
              activeColor: AppColors.primaryGreen,
              onChanged: (val) {
                onChanged(val);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chiqish',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Haqiqatan ham ilovadan chiqmoqchimisiz?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGreyLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Bekor qilish',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textBody,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Provider orqali chiqish
                          await Provider.of<ProfileProvider>(context, listen: false).logout(context);
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const InitialPage()),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Chiqish',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}