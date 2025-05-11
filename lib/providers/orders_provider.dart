import 'package:flutter/material.dart';

class Order {
  final String id;
  final double amount;
  final List<String> products;
  final DateTime dateTime;

  Order({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class OrdersProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  void addOrder(List<String> products, double total) {
    final newOrder = Order(
      id: DateTime.now().toString(),
      amount: total,
      products: products,
      dateTime: DateTime.now(),
    );
    _orders.insert(0, newOrder);
    notifyListeners();
  }
}
