import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_strings.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.infoBlueLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.infoBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.selectCategoryAndDiagnose,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.infoBlueDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}