import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(Icons.lock, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
          ),
          obscureText: true,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: onLogin,
          style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
          ),
          child: Text(
        'Iniciar Sesión',
        style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
