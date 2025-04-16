import 'package:restaurante_app/routes/app_routes.dart';

class AppPages {
  static const initial =
      AppRoutes.login;
  static const kanban = AppRoutes.kanban;

  static final routes = AppRoutes.getRoutes();
}
