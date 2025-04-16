import 'package:flutter/material.dart';

enum AuthStatus {
  Unauthenticated,
  Authenticating,
  Authenticated,
  Error,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.Unauthenticated;

  AuthStatus get status => _status;

  void login(String username, String password) async {
    _status = AuthStatus.Authenticating;
    notifyListeners();

    // Simulate a login delay
    await Future.delayed(Duration(seconds: 2));

    // Here you would normally check the credentials with a backend service
    if (username == 'user' && password == 'password') {
      _status = AuthStatus.Authenticated;
    } else {
      _status = AuthStatus.Error;
    }

    notifyListeners();
  }

  void logout() {
    _status = AuthStatus.Unauthenticated;
    notifyListeners();
  }
}