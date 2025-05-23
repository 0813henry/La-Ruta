import 'package:flutter/material.dart';
import '../../../core/services/servicio_firebase.dart';

class CategoriaSelector extends StatelessWidget {
  final Function(String?) onCategorySelected;

  const CategoriaSelector({
    required this.onCategorySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService().getCategoriesWithDetailsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay categorías disponibles.'));
        }

        final categories = snapshot.data!;
        final allCategories = [
          {
            'name': 'Todos',
            'imageUrl': 'https://cdn-icons-png.flaticon.com/512/126/126515.png',
            'count': categories.fold<int>(
              0,
              (sum, cat) => sum + (cat['count'] as int? ?? 0),
            ),
          },
          ...categories,
        ];

        return SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            itemCount: allCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final name = category['name'] ?? 'Sin nombre';
              final imageUrl = category['imageUrl'] ?? '';
              final count = category['count'] ?? 0;

              return GestureDetector(
                onTap: () => onCategorySelected(name == 'Todos' ? null : name),
                child: Material(
                  elevation: 4, // ✅ Elevación agregada aquí
                  borderRadius: BorderRadius.circular(6),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWide ? 18 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count producto${count == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isWide ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
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
