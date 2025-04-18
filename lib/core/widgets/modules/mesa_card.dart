import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class MesaCard extends StatelessWidget {
  final int numero; // Número de la mesa
  final String estado;
  final String tipo; // Principal, VIP, or Domicilio
  final String nombre; // Nombre de la mesa
  final VoidCallback onTap;
  final VoidCallback onChangeState; // Callback to change the mesa's state

  const MesaCard({
    required this.numero,
    required this.estado,
    required this.tipo,
    required this.nombre,
    required this.onTap,
    required this.onChangeState,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = estado == 'Libre'
        ? AppColors.success
        : estado == 'Ocupada'
            ? AppColors.danger
            : AppColors.warning; // Reservada
    final textColor = Colors.white;

    final icon = tipo == 'VIP'
        ? Icon(Icons.star, color: Colors.yellow.withOpacity(0.15), size: 120)
        : tipo == 'Principal'
            ? Icon(Icons.restaurant,
                color: Colors.green.withOpacity(0.15), size: 120)
            : Icon(Icons.delivery_dining,
                color: Colors.blue.withOpacity(0.15), size: 120); // Domicilio

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            color: backgroundColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$numero', // Mostrar solo el número
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  nombre, // Mostrar el nombre de la mesa
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onChangeState,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Cambiar Estado'),
                ),
              ],
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
