// Este archivo contiene validadores comunes para formularios.

class Validators {
  // Valida un correo electrónico
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  // Valida una contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // Valida que un campo no esté vacío
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  // Valida que un campo sea un número válido
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName debe ser un número válido';
    }
    return null;
  }
}
