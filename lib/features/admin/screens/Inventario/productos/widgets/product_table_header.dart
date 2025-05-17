import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/producto_model.dart';

class ProductTable extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onEdit;

  const ProductTable({
    super.key,
    required this.products,
    required this.onEdit,
  });

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  late List<Product> filteredProducts;
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'Categoría';

  @override
  void initState() {
    super.initState();
    // Forzar orientación horizontal permanente en esta pantalla
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);

    filteredProducts = widget.products;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();

    // Restaurar orientación a vertical al salir
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    super.dispose();
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = widget.products.where((product) {
        final matchesName = product.name.toLowerCase().contains(query);
        final matchesCategory = selectedCategory == 'Categoría' ||
            product.category == selectedCategory;
        return matchesName && matchesCategory;
      }).toList();
    });
  }

  void _onCategoryChanged(String? value) {
    if (value == null) return;
    setState(() {
      selectedCategory = value;
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: Column(
                children: [
                  _buildFilters(maxWidth - 32), // restamos padding horizontal
                  const SizedBox(height: 12),
                  // ⬇ Envolvemos el header en SizedBox para que tenga el mismo ancho
                  SizedBox(
                    width: maxWidth,
                    child: _buildTableHeader(),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (_, index) =>
                          // ⬇ Envolvemos cada fila en SizedBox también
                          SizedBox(
                        width: maxWidth,
                        child: _buildProductRow(filteredProducts[index]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilters(double maxWidth) {
    return Row(
      children: [
        // Búsqueda (toma todo el espacio excepto 180 px del dropdown)
        SizedBox(
          width: maxWidth - 185,
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Buscar...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildDropdown(),
      ],
    );
  }

  Widget _buildDropdown() {
    final categories = [
      'Categoría',
      ...{for (final product in widget.products) product.category}
    ];

    return Container(
      height: 40,
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedCategory,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        items: categories.map((cat) {
          return DropdownMenuItem(value: cat, child: Text(cat));
        }).toList(),
        onChanged: _onCategoryChanged,
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: const [
          _HeaderCell("Producto", flex: 2),
          _HeaderCell("Precio"),
          _HeaderCell("Stock"),
          _HeaderCell("Acciones", flex: 1),
        ],
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Producto (flex: 2)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: product.imageUrl != null
                      ? NetworkImage(product.imageUrl!)
                      : const AssetImage('assets/images/default.png')
                          as ImageProvider,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          // Precio
          Expanded(
            child: _DataCell('\$${product.price.toStringAsFixed(0)}'),
          ),

          // Stock
          Expanded(
            child: _DataCell('${product.stock}'),
          ),

          // Botón editar
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () {
                widget.onEdit(product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell(this.text);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
