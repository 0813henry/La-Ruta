// Este archivo contiene un widget reutilizable para mostrar un cuadro de diálogo de confirmación.
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text('Confirmar'),
        ),
      ],
    );
  }
}
