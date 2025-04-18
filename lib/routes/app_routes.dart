import 'package:flutter/material.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/gestion_inventario.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/producto.dart';
import 'package:restaurante_app/features/admin/screens/dashboard.dart';
import 'package:restaurante_app/features/auth/screens/login.dart';
import 'package:restaurante_app/features/auth/screens/registro.dart';
import 'package:restaurante_app/features/auth/screens/recuperar_contraseña.dart';
import 'package:restaurante_app/features/caja/screens/caja_home_screen.dart';
import 'package:restaurante_app/features/cocina/screens/cocina_home_screen.dart';
import 'package:restaurante_app/features/cocina/screens/pedido_detail_screen.dart';
import 'package:restaurante_app/features/mesero/screens/mesas_screen.dart';
import 'package:restaurante_app/features/mesero/screens/mesa_detail_screen.dart';
import 'package:restaurante_app/features/mesero/screens/nuevo_pedido_screen.dart';
import 'package:restaurante_app/features/mesero/screens/pedidos_screen.dart';
import 'package:restaurante_app/features/mesero/screens/resumen_screen.dart';
import 'package:restaurante_app/features/admin/screens/usuarios/gestion_usarios.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';
  static const dashboard = '/dashboard';
  static const mesas = '/mesas';
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

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      resetPassword: (context) => ResetPasswordScreen(),
      dashboard: (context) => DashboardScreen(),
      mesas: (context) => MesasScreen(),
      mesaDetail: (context) => MesaDetailScreen(
            mesaId: '', // Placeholder, se debe pasar dinámicamente
            estado: '', // Placeholder, se debe pasar dinámicamente
            nombre: '', // Placeholder, se debe pasar dinámicamente
          ),
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
    };
  }
}
