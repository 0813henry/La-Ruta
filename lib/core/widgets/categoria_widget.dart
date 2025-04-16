import 'package:flutter/material.dart';

class CategoriaWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  const CategoriaWidget({
    Key? key,
    required this.name,
    this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isSmallScreen ? 80 : 100,
                height: isSmallScreen ? 80 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[300],
                ),
                child: imageUrl == null
                    ? Icon(
                        Icons.category,
                        size: isSmallScreen ? 40 : 50,
                        color: Colors.grey[600],
                      )
                    : null,
              ),
              SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
