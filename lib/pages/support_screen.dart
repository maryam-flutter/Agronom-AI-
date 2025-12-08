import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Qo\'llab-quvvatlash',
            style: TextStyle(color: AppColors.textBlack, fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.support_agent_outlined,
              size: 80,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 24),
            const Text(
              "Tez orada ishga tushadi", // Bu yerda const qolishi mumkin
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                "Bu bo'lim hozirda ishlab chiqilmoqda. Tez orada siz uchun tayyor bo'ladi.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGreyLight,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}