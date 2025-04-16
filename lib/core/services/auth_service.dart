import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Este archivo contiene el servicio para gestionar la autenticación de usuarios.

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registro con Email y Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error en registro: $e");
      return null;
    }
  }

  // Inicio de sesión con Email y Password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print('Error en inicio de sesión: $e');
      }
      return null;
    } catch (e) {
      print('Error en inicio de sesión: $e');
      return null;
    }
  }

  // Inicio de sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error en inicio con Google: $e");
      return null;
    }
  }

  // Recuperar contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error en recuperación de contraseña: $e");
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Verificar si el usuario está autenticado
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }
}
