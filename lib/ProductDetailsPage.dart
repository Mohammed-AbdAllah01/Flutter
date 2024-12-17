import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'product.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  void _addToFavorites(BuildContext context, Product product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to add items to favorites!')),
      );
      return;
    }

    final userEmail = user.email;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email is not available!')),
      );
      return;
    }

    final userFavoritesRef = FirebaseDatabase.instance
        .ref('favorites/${userEmail.replaceAll('.', ',')}/favoritesItems');

    try {
      final newFavoriteRef = userFavoritesRef.push();
      await newFavoriteRef.set({
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added to favorites!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to favorites!')),
      );
      print('Error adding to favorites: $error');
    }
  }

  void _addToCart(BuildContext context, Product product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to add items to the cart!')),
      );
      return;
    }

    final userEmail = user.email;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email is not available!')),
      );
      return;
    }

    final userCartRef = FirebaseDatabase.instance
        .ref('carts/${userEmail.replaceAll('.', ',')}/cartItems');

    try {
      final newItemRef = userCartRef.push();
      await newItemRef.set({
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': 1,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added to cart!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to cart!')),
      );
      print('Error adding to cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splitting multiple image URLs from the `imageUrl` property if they are delimited by spaces.
    List<String> imageUrls = product.imageUrl.split(RegExp(r'\s+')).where((url) => url.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, .8),
      appBar: AppBar(
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Make the background transparent to show the image
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/th.jpeg'), // Use local image path
              fit: BoxFit.cover, // Ensure the image covers the entire AppBar
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Displaying the main product image with larger dimensions
              Container(
                height: MediaQuery.of(context).size.width > 450 ? 350 : 200,  // Dynamic height adjustment,  // Increased height
                width: double.infinity,  // Full width
                child: Image.network(
                  imageUrls.isNotEmpty ? imageUrls.first : '', // First image or fallback
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                product.name,
                style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20.0, color: Colors.green),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Category",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Text(
                product.category,
                style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Description",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Text(
                product.description ?? 'No description available.',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              // Responsive button layout based on screen width
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 450) {
                    // If screen width is less than 450, show buttons in a column
                    return Center(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _addToCart(context, product);
                            },
                            icon: const Icon(Icons.shopping_cart,color: Colors.black,),
                            label: const Text("Add to Cart",style: TextStyle(color: Colors.black),),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                          ),
                          const SizedBox(height: 8.0),
                          ElevatedButton.icon(
                            onPressed: () {
                              _addToFavorites(context, product);
                            },
                            icon: const Icon(Icons.star_outline,color: Colors.black,),
                            label: const Text("Add to Favorites",style: TextStyle(color: Colors.black),),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Default row layout
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _addToCart(context, product);
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text("Add to Cart"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _addToFavorites(context, product);
                          },
                          icon: const Icon(Icons.star_outline),
                          label: const Text("Add to Favorites"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
