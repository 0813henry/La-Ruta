import 'package:flutter/material.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/gestion_inventario.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/producto.dart';
import 'package:restaurante_app/features/admin/screens/dashboard.dart';
import 'package:restaurante_app/features/auth/screens/login.dart';
import 'package:restaurante_app/features/auth/screens/registro.dart';
import 'package:restaurante_app/features/auth/screens/recuperar_contraseña.dart';
import 'package:restaurante_app/features/caja/screens/caja_home_screen.dart';
import 'package:restaurante_app/features/caja/screens/historial_screen.dart';
import 'package:restaurante_app/features/cocina/screens/cocina_home_screen.dart';
import 'package:restaurante_app/features/cocina/screens/pedido_detail_screen.dart';
import 'package:restaurante_app/features/mesero/screens/detalles_mesa/mesa_detail_screen.dart';
import 'package:restaurante_app/features/mesero/screens/nuevo_pedido/nuevo_pedido_screen.dart';
import 'package:restaurante_app/features/mesero/screens/pedidos_screen.dart';
import 'package:restaurante_app/features/mesero/screens/resumen_screen.dart';
import 'package:restaurante_app/features/admin/screens/usuarios/gestion_usuarios.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/adicionales.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';
  static const dashboard = '/dashboard';
  static const mesaDetail = '/mesa-detail';
  static const nuevoPedido = '/nuevo-pedido';
  static const orders = '/orders';
  static const kitchenOrders = '/kitchen-orders';
  static const sales = '/sales';
  static const inventory = '/inventory';
  static const products = '/products';
  static const pedidos = '/pedidos';
  static const resumen = '/resumen';
  static const kanban = '/kanban';
  static const usuarios = '/usuarios';
  static const cashier = '/cashier';
  static const dividirCuenta = '/dividir-cuenta';
  static const historial = '/historial';
  static const adicionales = '/adicionales';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      resetPassword: (context) => ResetPasswordScreen(),
      dashboard: (context) => DashboardScreen(),
      pedidos: (context) => OrdersScreen(),
      mesaDetail: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        if (args == null ||
            !args.containsKey('mesaId') ||
            !args.containsKey('nombre') ||
            !args.containsKey('cliente') ||
            !args.containsKey('numero')) {
          throw Exception(
              'Faltan argumentos requeridos para MesaDetailScreen.');
        }

        return MesaDetailScreen(
          mesaId: args['mesaId'] ?? '',
          nombre: args['nombre'] ?? '',
          cliente: args['cliente'] ?? '',
          numero:
              args['numero'] ?? 0, // Aseguramos que el número sea proporcionado
        );
      },
      nuevoPedido: (context) => NuevoPedidoScreen(
            mesaId: '', // Placeholder, se debe pasar dinámicamente
            nombre: '', // Placeholder, se debe pasar dinámicamente
          ),
      orders: (context) => OrdersScreen(),
      kitchenOrders: (context) => KitchenOrdersScreen(),
      inventory: (context) => InventoryScreen(),
      products: (context) => ProductoScreen(),
      pedidos: (context) => OrdersScreen(),
      resumen: (context) => ResumenScreen(),
      kanban: (context) => CocinaHomeScreen(),
      usuarios: (context) => UsersScreen(),
      cashier: (context) => CajaHomeScreen(),
      historial: (context) => HistorialScreen(),
      adicionales: (context) => AdicionalesScreen(),
    };
  }
}
