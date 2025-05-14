import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/usuario_model.dart';
import 'package:restaurante_app/core/services/servicio_cloudinary.dart';
import 'package:restaurante_app/core/services/usuario_service.dart';
import 'package:restaurante_app/features/admin/screens/usuarios/widgets/upload_image_button.dart';
import 'package:restaurante_app/features/admin/screens/usuarios/widgets/user_role_selector.dart';
import 'package:restaurante_app/features/admin/screens/usuarios/widgets/user_text_field.dart';

final _usuarioService = UsuarioService();
final _cloudinaryService = CloudinaryService();

Future<void> showUserDialog({
  required BuildContext context,
  UserModel? user,
}) async {
  final isEditing = user != null;
  String email = user?.email ?? '';
  String password = '';
  String name = user?.name ?? '';
  String phone = user?.phone ?? '';
  String role = user?.role ?? 'Seleccione un rol';
  String? imageUrl = user?.color;

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx2, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            title: Text(
              isEditing ? 'Editar Usuario' : 'Agregar Usuario',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: (MediaQuery.of(context).size.width * 0.2)
                    .clamp(500.0, 800.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEditing) ...[
                      const SizedBox(height: 16),
                      UserTextField(
                        label: 'Email',
                        icon: Icons.email,
                        onChanged: (v) => email = v,
                      ),
                      const SizedBox(height: 16),
                      UserTextField(
                        label: 'Contraseña',
                        icon: Icons.lock,
                        obscure: true,
                        onChanged: (v) => password = v,
                      ),
                      const SizedBox(height: 16),
                    ],
                    UserTextField(
                      label: 'Nombre',
                      icon: Icons.person,
                      initial: name,
                      onChanged: (v) => name = v,
                    ),
                    const SizedBox(height: 16),
                    UserTextField(
                      label: 'Teléfono',
                      icon: Icons.phone,
                      initial: phone,
                      onChanged: (v) => phone = v,
                    ),
                    const SizedBox(height: 16),
                    UploadImageButton(
                      cloudinaryService: _cloudinaryService,
                      onImageUploaded: (url) {
                        imageUrl = url;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Imagen subida exitosamente'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    UserRoleSelector(
                      selectedRole: role,
                      onRoleSelected: (r) => setState(() => role = r),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx2),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: () async {
                  try {
                    if (isEditing) {
                      final updated = UserModel(
                        uid: user.uid,
                        email: user.email,
                        name: name,
                        role: role,
                        phone: phone,
                        color: imageUrl ?? user.color,
                        isActive: user.isActive,
                      );
                      await _usuarioService.actualizarUsuario(updated);
                    } else {
                      final cred = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      final u = cred.user!;
                      await _usuarioService.crearUsuario(
                        UserModel(
                          uid: u.uid,
                          email: email,
                          name: name,
                          role: role,
                          phone: phone,
                          color: imageUrl ?? '',
                          isActive: true,
                        ),
                      );
                    }
                    Navigator.pop(ctx2);
                  } catch (e) {
                    debugPrint('Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text(isEditing ? 'Guardar' : 'Agregar'),
              ),
            ],
          );
        },
      );
    },
  );
}
