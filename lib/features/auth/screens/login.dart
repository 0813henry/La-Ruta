import 'package:flutter/material.dart';
import 'package:restaurante_app/core/widgets/wtextbutton.dart';
import '../../../core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/model/usuario_model.dart';
import '../widgets/login_form.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Muestra un diálogo modal con indicador de carga.
  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(
              color: AppColors.secondary,
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    _showLoading();

    try {
      final user = await AuthService().loginWithEmail(email, password);
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        Navigator.of(context).pop(); // <-- cierro el modal

        if (userDoc.exists) {
          UserModel loggedInUser = UserModel.fromMap(userDoc.data()!);
          switch (loggedInUser.role) {
            case 'admin':
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 'cajero':
              Navigator.pushReplacementNamed(context, '/cashier');
              break;
            case 'mesero':
              Navigator.pushReplacementNamed(context, '/pedidos');
              break;
            case 'cocina':
              Navigator.pushReplacementNamed(context, '/kanban');
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rol de usuario desconocido')),
              );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no encontrado')),
          );
        }
      } else {
        Navigator.of(context).pop(); // <-- cierra el modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en el inicio de sesión')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // <-- cierra el modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos del usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo_2.png',
                        height: 180,
                      ),
                      Text(
                        'Bienvenido',
                        style: AppStyles.heading,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar',
                        style: AppStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onLogin: _login,
                      ),
                      const SizedBox(height: 10),
                      WTextButton(
                        label: '¿Olvidaste tu contraseña?',
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset-password');
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
