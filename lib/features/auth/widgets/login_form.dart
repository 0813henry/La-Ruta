import 'package:flutter/material.dart';
import 'package:restaurante_app/core/widgets/wbutton.dart';
import 'package:restaurante_app/core/widgets/wtext_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WTextField(
          controller: emailController,
          label: 'Correo Electronico',
          icon: Icons.email,
        ),
        SizedBox(height: 16),
        WTextField(
          controller: passwordController,
          label: 'Contraseña',
          icon: Icons.lock,
          obscureText: true,
        ),
        SizedBox(height: 16),
        WButton(
          label: 'Iniciar Sesión',
          onPressed: onLogin,
        ),
      ],
    );
  }
}
