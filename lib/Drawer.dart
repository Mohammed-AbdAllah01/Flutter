import 'package:ecommercestore/AboutUsPage.dart';
import 'package:ecommercestore/AddToCartPage.dart';
import 'package:ecommercestore/FavouritePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  // Method to fetch the current user's name from Firebase Realtime Database
  Future<String?> _getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
    final snapshot = await userRef.child('name').get();

    if (snapshot.exists) {
      return snapshot.value.toString();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250, // 70% of screen width
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://tse2.mm.bing.net/th?id=OIP.P1VFAS_VBwXfrwQveHBxoQHaFj&pid=Api&P=0&h=220'), // Replace with your image URL
                fit: BoxFit.cover, // Ensures the image covers the entire area
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 10),
                FutureBuilder<String?>(
                  future: _getCurrentUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Loading...',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Error loading name',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      );
                    } else if (snapshot.hasData) {
                      return Text(
                        snapshot.data ?? 'Guest',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return const Text(
                        'Guest',
                        style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.black),
            title: const Text(
              'Cart',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddToCartPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outlined, color: Colors.black),
            title: const Text(
              'Favorites',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.black),
            title: const Text(
              'About Us',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
