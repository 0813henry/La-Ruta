// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';
// import '../../../../core/model/usuario_model.dart';
// import '../../../../core/services/usuario_service.dart';
// import '../../../../core/services/servicio_cloudinary.dart';

// class UsersScreen extends StatelessWidget {
//   final _usuarioService = UsuarioService();
//   final _cloudinaryService = CloudinaryService();

//   UsersScreen({Key? key}) : super(key: key);

//   Future<void> _showUserDialog({
//     required BuildContext context,
//     UserModel? user,
//   }) async {
//     final isEditing = user != null;
//     String email = user?.email ?? '';
//     String password = '';
//     String name = user?.name ?? '';
//     String phone = user?.phone ?? '';
//     String role = user?.role ?? 'Seleccione un rol';
//     String? imageUrl = user?.color;

//     await showDialog(
//       context: context,
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (ctx2, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20)),
//               title: Text(isEditing ? 'Editar Usuario' : 'Agregar Usuario'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (!isEditing) ...[
//                       _buildTextField(
//                         label: 'Email',
//                         icon: Icons.email,
//                         onChanged: (v) => email = v,
//                       ),
//                       const SizedBox(height: 16),
//                       _buildTextField(
//                         label: 'Contraseña',
//                         icon: Icons.lock,
//                         obscure: true,
//                         onChanged: (v) => password = v,
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                     _buildTextField(
//                       label: 'Nombre',
//                       icon: Icons.person,
//                       initial: name,
//                       onChanged: (v) => name = v,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       label: 'Teléfono',
//                       icon: Icons.phone,
//                       initial: phone,
//                       onChanged: (v) => phone = v,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         final picker = ImagePicker();
//                         final file =
//                             await picker.pickImage(source: ImageSource.gallery);
//                         if (file != null) {
//                           imageUrl = await _cloudinaryService
//                               .uploadImage(File(file.path));
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Imagen subida exitosamente')),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.upload),
//                       label: const Text('Subir Foto'),
//                     ),
//                     const SizedBox(height: 16),
//                     // Selector de rol con PopupMenuButton y StatefulBuilder
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: PopupMenuButton<String>(
//                         initialValue: role,
//                         onSelected: (r) {
//                           setState(() {
//                             role = r;
//                           });
//                         },
//                         itemBuilder: (_) => const [
//                           PopupMenuItem(value: 'admin', child: Text('Admin')),
//                           PopupMenuItem(value: 'cajero', child: Text('Cajero')),
//                           PopupMenuItem(value: 'mesero', child: Text('Mesero')),
//                           PopupMenuItem(value: 'cocina', child: Text('Cocina')),
//                         ],
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 8),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade400),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 role[0].toUpperCase() + role.substring(1),
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                               const Icon(Icons.arrow_drop_down),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx2),
//                   child: const Text('Cancelar'),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//                   onPressed: () async {
//                     try {
//                       if (isEditing) {
//                         final updated = UserModel(
//                           uid: user!.uid,
//                           email: user.email,
//                           name: name,
//                           role: role,
//                           phone: phone,
//                           color: imageUrl ?? user.color,
//                           isActive: user.isActive,
//                         );
//                         await _usuarioService.actualizarUsuario(updated);
//                       } else {
//                         final cred = await FirebaseAuth.instance
//                             .createUserWithEmailAndPassword(
//                           email: email,
//                           password: password,
//                         );
//                         final u = cred.user!;
//                         await _usuarioService.crearUsuario(
//                           UserModel(
//                             uid: u.uid,
//                             email: email,
//                             name: name,
//                             role: role,
//                             phone: phone,
//                             color: imageUrl ?? '',
//                             isActive: true,
//                           ),
//                         );
//                       }
//                       Navigator.pop(ctx2);
//                     } catch (e) {
//                       debugPrint('Error: $e');
//                     }
//                   },
//                   child: Text(isEditing ? 'Guardar' : 'Agregar'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required IconData icon,
//     bool obscure = false,
//     String initial = '',
//     required ValueChanged<String> onChanged,
//   }) {
//     return TextField(
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       obscureText: obscure,
//       controller: TextEditingController(text: initial),
//       onChanged: onChanged,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AdminScaffoldLayout(
//       title: Row(
//         children: [
//           const Expanded(child: Text('Gestión de Usuarios')),
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => _showUserDialog(context: context),
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<UserModel>>(
//         stream: _usuarioService.obtenerUsuarios(),
//         builder: (ctx, snap) {
//           if (!snap.hasData)
//             return const Center(child: CircularProgressIndicator());
//           final list = snap.data!;
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: list.length,
//             itemBuilder: (ctx, i) => _UserCard(
//               user: list[i],
//               onToggle: (active) =>
//                   _usuarioService.cambiarEstadoUsuario(list[i].uid, active),
//               onEdit: () => _showUserDialog(context: context, user: list[i]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _UserCard extends StatelessWidget {
//   final UserModel user;
//   final ValueChanged<bool> onToggle;
//   final VoidCallback onEdit;

//   const _UserCard({
//     Key? key,
//     required this.user,
//     required this.onToggle,
//     required this.onEdit,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.grey.shade200,
//             backgroundImage:
//                 user.color.startsWith('http') ? NetworkImage(user.color) : null,
//             child: user.color.startsWith('http')
//                 ? null
//                 : const Icon(Icons.person, size: 30, color: Colors.teal),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(user.name,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Text(user.role,
//                     style:
//                         TextStyle(fontSize: 14, color: Colors.grey.shade600)),
//                 const SizedBox(height: 4),
//                 Text(user.phone,
//                     style:
//                         TextStyle(fontSize: 14, color: Colors.grey.shade600)),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               IconButton(
//                 icon: Icon(user.isActive ? Icons.toggle_on : Icons.toggle_off,
//                     size: 28, color: user.isActive ? Colors.green : Colors.red),
//                 onPressed: () => onToggle(!user.isActive),
//               ),
//               IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: onEdit),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
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
