import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class MesaCard extends StatelessWidget {
  final int numero; // Número de la mesa
  final String estado;
  final String tipo; // Principal o VIP
  final VoidCallback onTap;

  const MesaCard({
    required this.numero,
    required this.estado,
    required this.tipo,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = estado == 'Libre'
        ? AppColors.success
        : estado == 'Ocupada'
            ? AppColors.danger
            : AppColors.warning;

    final icon = tipo == 'VIP'
        ? Icon(Icons.star, color: Colors.yellow.withOpacity(0.15), size: 120)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            color: color.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '$numero', // Mostrar solo el número
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          if (icon != null)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: icon,
              ),
            ),
        ],
      ),
    );
  }
}
