import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const heading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: 'DancingScript', // Font inspired by menuTipoLetra.png
    color: AppColors.primary,
  );

  static const subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: 'Roboto',
    color: AppColors.secondary,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Roboto',
    color: AppColors.textPrimary,
  );

  static const buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'DancingScript', // Font inspired by menuTipoLetra.png
    color: AppColors.white,
  );

  static const labelText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    color: AppColors.metallicGray,
  );
}
