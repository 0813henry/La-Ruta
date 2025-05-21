import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    final double cardHeight = isSmallScreen ? 170 : 190;
    final double iconSize = isSmallScreen ? 20 : 50;
    final double padding = isSmallScreen ? 20 : 20;
    final double fontSize = isSmallScreen ? 14 : 15;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2)
              ],
            ),
            padding: EdgeInsets.all(padding),
            height: cardHeight,
            width: double.infinity,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.broken_image, size: iconSize),
                  )
                : Icon(Icons.image_not_supported, size: iconSize),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
