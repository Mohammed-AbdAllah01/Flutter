import 'package:ecommercestore/AddToCartPage.dart';
import 'package:ecommercestore/FavouritePage.dart';
import 'package:ecommercestore/ProductCard.dart';
import 'package:ecommercestore/ProductDetailsPage.dart';
import 'package:flutter/material.dart';
import 'product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchProducts() async {
    final databaseRef = FirebaseDatabase.instance.ref('products');
    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final List<Product> loadedProducts = [];
        final Set<String> loadedCategories = {'All'}; // Default category

        for (final entry in snapshot.children) {
          final productData = Map<String, dynamic>.from(entry.value as Map);
          loadedProducts.add(Product(
            name: productData['name'] ?? 'Unknown',
            price: productData['price']?.toDouble() ?? 0.0,
            imageUrl: productData['imageUrl'] ?? '',
            category: productData['category'] ?? 'Other',
            description: productData['description'] ,
          ));
          loadedCategories.add(productData['category'] ?? 'Other');
        }

        setState(() {
          _products = loadedProducts;
          _filteredProducts = loadedProducts;
          _categories = loadedCategories.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('No products found in the database.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching products: $error');
    }
  }
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((product) =>
      product.name.toLowerCase().contains(query) &&
          (_selectedCategory == 'All' || product.category == _selectedCategory))
          .toList();
    });
  }
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }
  void _addToFavorites(Product product) async {
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

    final userFavoritesRef = FirebaseDatabase.instance.ref('favorites/${userEmail.replaceAll('.', ',')}/favoritesItems');

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
  void _addToCart(Product product) async {
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

    final userCartRef = FirebaseDatabase.instance.ref('carts/${userEmail.replaceAll('.', ',')}/cartItems');

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
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (screenWidth < 400) {
      crossAxisCount = 1;
    } else if (screenWidth < 950) {
      crossAxisCount = 2;
    } else if (screenWidth < 1050) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Jewel',
          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 40),
        ),
        backgroundColor: Colors.transparent, // Make the background transparent to show the image
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://tse2.mm.bing.net/th?id=OIP.P1VFAS_VBwXfrwQveHBxoQHaFj&pid=Api&P=0&h=220'), // Replace with your image URL
              fit: BoxFit.cover, // Ensure the image covers the entire AppBar
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout_outlined, color: Colors.black,size:40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddToCartPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.star_outline, color: Colors.black,size:40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red,size:40),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight * 2),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    border: OutlineInputBorder(),
                    hoverColor: Colors.black,
                    hintStyle: TextStyle(color: Colors.black),
                    suffixIcon: Icon(Icons.search, color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () => _selectCategory(category),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0,),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0,),
                          decoration: BoxDecoration(
                            color: _selectedCategory == category ? Colors.black : Colors.black,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),


      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: _filteredProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(product: product),
                  ),
                );
              },
              child: ProductCard(
                product: product,
                onAddToCart: () => _addToCart(product),
                onAddToFavorites: () => _addToFavorites(product),
              ),
            );
          },
        ),
      ),
    );
  }
}