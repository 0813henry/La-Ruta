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

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final user = await AuthService().loginWithEmail(email, password);
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
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
              Navigator.pushReplacementNamed(context, '/mesas');
              break;
            case 'cocina':
              Navigator.pushReplacementNamed(context, '/kanban');
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Rol de usuario desconocido')),
              );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario no encontrado')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener datos del usuario: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el inicio de sesión')),
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
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo negro con opacidad
                    borderRadius:
                        BorderRadius.circular(10), // Bordes redondeados
                  ),
                  padding: EdgeInsets.all(20.0), // Espaciado interno
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
                      SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar',
                        style: AppStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 24),
                      LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onLogin: _login,
                      ),
                      SizedBox(height: 10),
                      WTextButton(
                        label: '¿Olvidaste tu contraseña?',
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset-password');
                        },
                      ),
                      SizedBox(height: 10),
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
