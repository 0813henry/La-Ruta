import 'package:flutter/material.dart';

class InventoryProvider with ChangeNotifier {
  final Map<String, int> _inventory = {};

  Map<String, int> get inventory => _inventory;

  void addItem(String item, int quantity) {
    if (_inventory.containsKey(item)) {
      _inventory[item] = _inventory[item]! + quantity;
    } else {
      _inventory[item] = quantity;
    }
    notifyListeners();
  }

  void removeItem(String item, int quantity) {
    if (_inventory.containsKey(item) && _inventory[item]! >= quantity) {
      _inventory[item] = _inventory[item]! - quantity;
      if (_inventory[item] == 0) {
        _inventory.remove(item);
      }
      notifyListeners();
    }
  }

  void clearInventory() {
    _inventory.clear();
    notifyListeners();
  }
}
