// Este archivo contiene utilidades relacionadas con la impresión de datos en la aplicación.

import 'dart:developer';

class Printers {
  // Método para imprimir mensajes de depuración en la consola.
  // Útil para rastrear errores o verificar el flujo de ejecución.
  static void debug(String message) {
    log('[DEBUG]: $message');
  }

  // Método para imprimir mensajes de información en la consola.
  // Útil para mostrar información general durante la ejecución.
  static void info(String message) {
    log('[INFO]: $message');
  }

  // Método para imprimir mensajes de advertencia en la consola.
  // Útil para alertar sobre posibles problemas no críticos.
  static void warning(String message) {
    log('[WARNING]: $message');
  }

  // Método para imprimir mensajes de error en la consola.
  // Útil para registrar errores críticos en la aplicación.
  static void error(String message) {
    log('[ERROR]: $message');
  }
}