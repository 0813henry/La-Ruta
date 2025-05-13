import 'package:flutter/material.dart';
import 'package:restaurante_app/features/admin/screens/usuarios/widgets/user_card.dart';
import 'package:restaurante_app/features/admin/screens/usuarios/widgets/user_dialog.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';
import '../../../../core/model/usuario_model.dart';
import '../../../../core/services/usuario_service.dart';

class UsersScreen extends StatelessWidget {
  final _usuarioService = UsuarioService();

  UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffoldLayout(
      title: Row(
        children: [
          const Expanded(child: Text('Gestión de Usuarios')),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showUserDialog(context: context),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _usuarioService.obtenerUsuarios(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (ctx, i) => UserCard(
              user: list[i],
              onToggle: (active) =>
                  _usuarioService.cambiarEstadoUsuario(list[i].uid, active),
              onEdit: () => showUserDialog(context: context, user: list[i]),
            ),
          );
        },
      ),
    );
  }
}
