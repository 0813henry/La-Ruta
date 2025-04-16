// Este archivo contiene una función para formatear valores numéricos como moneda.
import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final NumberFormat formatter =
      NumberFormat.currency(locale: 'es_ES', symbol: '€');
  return formatter.format(amount);
}
