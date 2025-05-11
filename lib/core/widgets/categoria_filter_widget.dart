import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';

class CategoriaFilterWidget extends StatelessWidget {
  final Function(String?) onFilterSelected;

  const CategoriaFilterWidget({
    super.key,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService().getCategoriesWithDetailsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No hay categorías disponibles');
        }
        final categories = snapshot.data!;
        print('Categorías recibidas: $categories'); // Depuración de datos
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text(
                'Seleccionar categoría',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              items: [
                DropdownMenuItem(
                  value: 'Todos',
                  child: Text('Todos', style: TextStyle(fontSize: 16)),
                ),
                ...categories.map<DropdownMenuItem<String>>((category) {
                  final categoryName =
                      category['name'] as String? ?? 'Sin nombre';
                  return DropdownMenuItem(
                    value: categoryName,
                    child: Text(categoryName, style: TextStyle(fontSize: 16)),
                  );
                }),
              ],
              onChanged: onFilterSelected,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
