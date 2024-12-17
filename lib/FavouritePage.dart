import 'package:ecommercestore/ProductDetailsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  // Fetch favorites from Firebase
  void _fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userEmail = user.email!; // Retrieve user's email
    final formattedEmail = userEmail.replaceAll('.', ','); // Format email to use as key
    final favoritesRef = FirebaseDatabase.instance.ref('favorites/$formattedEmail/favoritesItems');

    try {
      final snapshot = await favoritesRef.get();
      if (snapshot.exists) {
        final List<Map<String, dynamic>> loadedFavorites = [];
        snapshot.children.forEach((entry) {
          final itemData = Map<String, dynamic>.from(entry.value as Map);
          loadedFavorites.add({
            'id': entry.key, // Add the key (id) of the item for removal later
            'name': itemData['name'] ?? 'Unknown',
            'price': itemData['price']?.toDouble() ?? 0.0,
            'imageUrl': itemData['imageUrl'] ?? '',
          });
        });
        setState(() {
          _favoriteItems = loadedFavorites;
          _isLoading = false;
        });
      } else {
        setState(() {
          _favoriteItems = [];
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching favorites: $error');
    }
  }

  // Remove an item from favorites
  void _removeFromFavorites(String itemId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final userEmail = user.email!; // Retrieve user's email
    final formattedEmail = userEmail.replaceAll('.', ','); // Format email to use as key
    final favoritesRef = FirebaseDatabase.instance.ref('favorites/$formattedEmail/favoritesItems/$itemId');

    try {
      await favoritesRef.remove();
      setState(() {
        _favoriteItems.removeWhere((item) => item['id'] == itemId); // Remove from local list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from favorites!')),
      );
    } catch (error) {
      print('Error removing item from favorites: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Favorites'), backgroundColor: Colors.transparent, // Make the background transparent to show the image
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://tse2.mm.bing.net/th?id=OIP.P1VFAS_VBwXfrwQveHBxoQHaFj&pid=Api&P=0&h=220'), // Replace with your image URL
              fit: BoxFit.cover, // Ensure the image covers the entire AppBar
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteItems.isEmpty
          ? const Center(child: Text('No favorite items found'))
          : ListView.builder(

        itemCount: _favoriteItems.length,
        itemBuilder: (ctx, index) {
          final item = _favoriteItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: ListTile(
              leading: Image.network(item['imageUrl']),
              title: Text(item['name']),
              subtitle: Text('\$${item['price']}'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _removeFromFavorites(item['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
