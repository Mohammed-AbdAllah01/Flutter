import 'package:ecommercestore/product.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onAddToFavorites;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onAddToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Add to Cart Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart, color: Colors.black),
                    label: MediaQuery.of(context).size.width > 400 && MediaQuery.of(context).size.width < 700
                        ? const SizedBox() // Empty widget to hide the text on small screens
                        : const Text('Add to Cart', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 8), // Space between buttons
                // Add to Favorite Button
                ElevatedButton.icon(
                  onPressed: onAddToFavorites,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.star_border, color: Colors.black),
                  label: MediaQuery.of(context).size.width < 600 || MediaQuery.of(context).size.width > 800
                      ? const SizedBox() // Empty widget to hide the text on small screens
                      : const Text('Add to Favorites', style: TextStyle(color: Colors.black)),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
