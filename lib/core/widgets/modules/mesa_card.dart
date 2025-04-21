import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class MesaCard extends StatelessWidget {
  final int numero; // Número de la mesa
  final String estado;
  final String tipo; // Principal, VIP, or Domicilio
  final String nombre; // Nombre de la mesa
  final VoidCallback onTap;
  final VoidCallback onLongPress; // Callback to change the mesa's state

  const MesaCard({
    required this.numero,
    required this.estado,
    required this.tipo,
    required this.nombre,
    required this.onTap,
    required this.onLongPress, // Use onLongPress instead of a button
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth > 600 ? 80.0 : 50.0;

    final backgroundColor = estado == 'Libre'
        ? Colors.greenAccent
        : estado == 'Ocupada'
            ? Colors.redAccent
            : Colors.orangeAccent; // Reservada
    final textColor = Colors.white;

    final icon = tipo == 'VIP'
        ? Icon(Icons.star, color: Colors.yellow, size: iconSize)
        : tipo == 'Principal'
            ? Icon(Icons.restaurant, color: Colors.blue, size: iconSize)
            : Icon(Icons.delivery_dining,
                color: Colors.purple, size: iconSize); // Domicilio

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress, // Handle long press for state change
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  '#$numero', // Mostrar el número de la mesa
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              icon,
              SizedBox(height: 8),
              Text(
                nombre,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limit the text to one line
                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
              ),
              SizedBox(height: 8),
              Text(
                'Estado: $estado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
