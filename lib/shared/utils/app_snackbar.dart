import 'package:flutter/material.dart';
import '../../app/theme.dart';

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isError
                  ? AppColors.hot.withValues(alpha: 0.15)
                  : AppColors.savings.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isError ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: isError ? AppColors.hot : AppColors.savings,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isError
              ? AppColors.hot.withValues(alpha: 0.3)
              : AppColors.savings.withValues(alpha: 0.3),
        ),
      ),
      elevation: 10,
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
