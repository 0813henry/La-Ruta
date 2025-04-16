// Este archivo contiene funciones auxiliares y utilidades generales
// que pueden ser usadas en toda la aplicación.

import 'package:intl/intl.dart';

/// Convierte una cadena de texto en formato de fecha a un objeto DateTime.
DateTime parseDate(String dateString) {
  return DateTime.parse(dateString);
}

/// Formatea un objeto DateTime a una cadena de texto en formato legible.
String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
  final DateFormat formatter = DateFormat(format);
  return formatter.format(date);
}

/// Valida si un correo electrónico tiene un formato válido.
bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

/// Capitaliza la primera letra de una cadena de texto.
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/// Calcula el porcentaje de un valor dado.
double calculatePercentage(double value, double total) {
  if (total == 0) return 0;
  return (value / total) * 100;
}

/// Genera un identificador único basado en la fecha y hora actual.
String generateUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}