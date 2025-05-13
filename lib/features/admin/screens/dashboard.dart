import 'package:flutter/material.dart';
import 'package:restaurante_app/features/admin/widgets/admin_dashboard/sidebar_menu.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AdminScaffoldLayout(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_3.png',
                width: screenWidth * 0.5,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Bienvenidos!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Despues se soluciona o se agrega mas cositas del dashboard2
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
