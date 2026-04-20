import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SignInOption extends StatelessWidget {
  final String textBefore;
  final String actionText;
  final VoidCallback onTap;

  const SignInOption({
    super.key,
    required this.textBefore,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          textBefore,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.bordeaux,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
