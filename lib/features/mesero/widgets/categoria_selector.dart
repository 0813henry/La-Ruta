import 'package:flutter/material.dart';
import '../../../core/services/servicio_firebase.dart';

class CategoriaSelector extends StatelessWidget {
  final Function(String?) onCategorySelected;

  const CategoriaSelector({
    required this.onCategorySelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService().getCategoriesWithDetailsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay categorías disponibles.'));
        }
        final categories = snapshot.data!;
        return DropdownButton<String>(
          hint: Text('Seleccionar categoría'),
          items: [
            DropdownMenuItem(
              value: 'Todos',
              child: Text('Todos'),
            ),
            ...categories.map((category) {
              final categoryName = category['name'] as String? ?? 'Sin nombre';
              return DropdownMenuItem(
                value: categoryName,
                child: Text(categoryName),
              );
            }).toList(),
          ],
          onChanged: onCategorySelected,
        );
      },
    );
  }
}
