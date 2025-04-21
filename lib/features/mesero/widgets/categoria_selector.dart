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

        return SizedBox(
          height: 120, // Altura del carrusel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category['name'] as String? ?? 'Sin nombre';
              final categoryImage = category['imageUrl'] as String? ?? '';

              return GestureDetector(
                onTap: () => onCategorySelected(categoryName),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.network(
                          categoryImage,
                          height: 80,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 80,
                            width: 100,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
