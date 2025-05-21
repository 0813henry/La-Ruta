import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/core/widgets/categoria_filter_widget.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return AdminScaffoldLayout(
      title: const Text(
        'Gestión de Inventarios',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CategoriaFilterWidget(
                  onFilterSelected: (selectedCategory) {
                    setState(() {
                      _selectedCategory = selectedCategory;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<List<Product>>(
                    stream: _firebaseService
                        .getFilteredProductsStream(_selectedCategory),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error al cargar los productos'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No hay productos disponibles'));
                      }

                      final products = snapshot.data!;
                      return ListView.separated(
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final stockController = TextEditingController(
                            text: product.stock.toString(),
                          );

                          return Card(
                            elevation: 1,
                            color: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: product.imageUrl != null &&
                                            product.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            product.imageUrl!,
                                            width: isMobile ? 80 : 100,
                                            height: isMobile ? 80 : 100,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.image_not_supported,
                                            size: 60,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Stepper personalizado para stock
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 3,
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  color: AppColors.cancelado,
                                                ),
                                                splashRadius: 20,
                                                onPressed: () async {
                                                  final newStock =
                                                      product.stock - 1;
                                                  if (newStock >= 0) {
                                                    await _firebaseService
                                                        .updateProduct(
                                                      product.copyWith(
                                                          stock: newStock),
                                                    );
                                                  }
                                                },
                                              ),
                                              Container(
                                                width: 40,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                                child: TextField(
                                                  controller: stockController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                  ),
                                                  onSubmitted: (value) async {
                                                    final newStock =
                                                        int.tryParse(value) ??
                                                            product.stock;
                                                    if (newStock >= 0) {
                                                      await _firebaseService
                                                          .updateProduct(
                                                        product.copyWith(
                                                            stock: newStock),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: AppColors.accent,
                                                ),
                                                splashRadius: 20,
                                                onPressed: () async {
                                                  final newStock =
                                                      product.stock + 1;
                                                  await _firebaseService
                                                      .updateProduct(
                                                    product.copyWith(
                                                        stock: newStock),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
