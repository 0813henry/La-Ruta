import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/model/usuario_model.dart';
import '../../../auth/widgets/role_selector.dart';
import '../../../../core/services/usuario_service.dart';
import '../../../../core/services/servicio_cloudinary.dart';

class UsersScreen extends StatelessWidget {
  final UsuarioService _usuarioService = UsuarioService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  UsersScreen({super.key});

  Future<void> _addUser(BuildContext context) async {
    String email = '';
    String password = '';
    String name = '';
    String role = 'admin';
    String phone = '';
    String? imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Agregar Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => email = value,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) => password = value,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) => name = value,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) => phone = value,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      imageUrl = await _cloudinaryService
                          .uploadImage(File(pickedFile.path));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Imagen subida exitosamente')),
                      );
                    }
                  },
                  icon: Icon(Icons.upload),
                  label: Text('Subir Foto'),
                ),
                SizedBox(height: 16),
                RoleSelector(
                  selectedRole: role,
                  onRoleSelected: (selectedRole) {
                    role = selectedRole;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                  final user = userCredential.user;
                  if (user != null) {
                    UserModel newUser = UserModel(
                      uid: user.uid,
                      email: email,
                      name: name,
                      role: role,
                      phone: phone,
                      color: imageUrl ?? '', // Usa la imagen si está disponible
                      isActive: true,
                    );
                    await _usuarioService.crearUsuario(newUser);
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error al agregar usuario: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editUser(BuildContext context, UserModel user) async {
    String name = user.name;
    String role = user.role;
    String phone = user.phone;
    String? imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Editar Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => name = value,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: TextEditingController(text: user.name),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) => phone = value,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: TextEditingController(text: user.phone),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      imageUrl = await _cloudinaryService
                          .uploadImage(File(pickedFile.path));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Imagen subida exitosamente')),
                      );
                    }
                  },
                  icon: Icon(Icons.upload),
                  label: Text('Subir Foto'),
                ),
                SizedBox(height: 16),
                RoleSelector(
                  selectedRole: role,
                  onRoleSelected: (selectedRole) {
                    role = selectedRole;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserModel updatedUser = UserModel(
                    uid: user.uid,
                    email: user.email,
                    name: name,
                    role: role,
                    phone: phone,
                    color: imageUrl ??
                        user.color, // Usa la imagen si está disponible
                    isActive: user.isActive,
                  );
                  await _usuarioService.actualizarUsuario(updatedUser);
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error al editar usuario: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Gestión de Usuarios')),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addUser(context),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _usuarioService.obtenerUsuarios(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    backgroundImage: user.color.startsWith('http')
                        ? NetworkImage(user.color)
                        : null,
                    child: user.color.startsWith('http')
                        ? null
                        : Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(user.name),
                  subtitle: Text('Rol: ${user.role}\nTeléfono: ${user.phone}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          user.isActive ? Icons.toggle_on : Icons.toggle_off,
                          color: user.isActive ? Colors.green : Colors.red,
                        ),
                        onPressed: () {
                          _usuarioService.cambiarEstadoUsuario(
                              user.uid, !user.isActive);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editUser(context, user),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
