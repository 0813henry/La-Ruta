import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String? pedidoId;
  final String title;
  final double amount;
  final String paymentMethod;
  final DateTime date;

  Transaction({
    required this.id,
    this.pedidoId,
    required this.title,
    required this.amount,
    required this.paymentMethod,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedidoId': pedidoId,
      'title': title,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'date': Timestamp.fromDate(date), // Convertir a Timestamp de Firestore
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      pedidoId: map['pedidoId'],
      title: map['title'],
      amount: map['amount'],
      paymentMethod: map['paymentMethod'],
      date: (map['date'] as Timestamp)
          .toDate(), // Convertir de Timestamp a DateTime
    );
  }

  get status => null;

  get estado => null;
}
