import 'package:flutter/material.dart';

class AppColors {
  // Colores principales basados en el logo
  static const primary = Color(0xFFB71C1C); // Rojo oscuro (principal del logo)
  static const secondary =
      Color(0xFFFFC107); // Amarillo dorado (detalles del logo)
  static const accent = Color(0xFF4CAF50); // Verde (para contrastes y botones)

  // Colores para estados
  static const success = Color(0xFF4CAF50); // Verde éxito
  static const warning = Color(0xFFFFC107); // Amarillo advertencia
  static const danger = Color(0xFFD32F2F); // Rojo peligro

  //Color de Container
  static const containerColor =
      Color.fromRGBO(126, 7, 7, 1); // Azul claro para contenedores
  // Colores para texto
  static const textPrimary = Color(0xFF212121); // Negro para texto principal
  static const textSecondary = Color(0xFF757575); // Gris para texto secundario

  // Colores de fondo
  static const background = Color(0xFFF5F5F5); // Fondo claro
  static const cardBackground = Color(0xFFFFFFFF); // Fondo de tarjetas

  // Colores adicionales
  static const white = Color(0xFFFFFFFF); // Blanco
  static const black = Color(0xFF000000); // Negro
  static const metallicGray = Color(0xFFB0BEC5); // Gris metálico
  static const coolGray = Color(0xFFCFD8DC); // Gris frío
  static const darkOrange = Color(0xFFEF6C00); // Naranja oscuro (para énfasis)

  // Colores para Tipos de Pedido
  static const domicilio = Color(0xFF4FC3F7); // Azul cielo
  static const vip = Color(0xFFFFD700); // Dorado
  static const principal = Color(0xFF81C784); // Verde claro

  // Colores para Estados del Pedido
  static const pendiente = Color(0xFFB0BEC5); // Gris claro
  static const enPreparacion = Color(0xFFFFA726); // Naranja
  static const listoParaServir = Color(0xFFAED581); // Verde lima
  static const enCamino = Color(0xFF1976D2); // Azul oscuro
  static const entregado = Color(0xFF388E3C); // Verde oscuro
  static const cancelado = Color(0xFFE57373); // Rojo
}
