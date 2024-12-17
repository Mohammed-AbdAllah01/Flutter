import 'package:ecommercestore/CheckOutPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddToCartPage extends StatefulWidget {
  const AddToCartPage({super.key});

  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  List<String> _cartKeys = []; // To store Firebase keys for deletion
  bool _isLoading = true;

  final double _deliveryCharges = 50.0; // Fixed delivery charges
  final double _taxPercentage = 15.0; // Tax percentage

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  void _fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      print('User is not logged in.');
      return;
    }

    final userEmail = user.email; // Get the current user's email
    if (userEmail == null) {
      setState(() {
        _isLoading = false;
      });
      print('User email is not available.');
      return;
    }

    // Replace periods with commas in the email to make it a valid Firebase key
    final userEmailKey = userEmail.replaceAll('.', ',');

    final cartRef = FirebaseDatabase.instance.ref('carts/$userEmailKey/cartItems');

    try {
      final snapshot = await cartRef.get();
      if (snapshot.exists) {
        final List<Map<String, dynamic>> loadedCartItems = [];
        final List<String> loadedKeys = [];
        for (final entry in snapshot.children) {
          final itemData = Map<String, dynamic>.from(entry.value as Map);
          loadedCartItems.add({
            'name': itemData['name'] ?? 'Unknown',
            'price': itemData['price']?.toDouble() ?? 0.0,
            'imageUrl': itemData['imageUrl'] ?? '',
            'quantity': itemData['quantity'] ?? 1,
          });
          loadedKeys.add(entry.key!); // Store Firebase keys
        }
        setState(() {
          _cartItems = loadedCartItems;
          _cartKeys = loadedKeys;
          _isLoading = false;
        });
      } else {
        setState(() {
          _cartItems = [];
          _cartKeys = [];
          _isLoading = false;
        });
        print('Cart is empty.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching cart items: $error');
    }
  }


  void _updateQuantity(int index, int newQuantity) async {
    if (newQuantity < 1) return; // Prevent quantity less than 1
    final cartRef = FirebaseDatabase.instance.ref('cart');
    final keyToUpdate = _cartKeys[index];

    try {
      await cartRef.child(keyToUpdate).update({'quantity': newQuantity});
      setState(() {
        _cartItems[index]['quantity'] = newQuantity; // Update local list
      });
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }

  void _deleteCartItem(int index) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not logged in.')),
      );
      return;
    }

    final userEmail = user.email; // Get the current user's email
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email is not available.')),
      );
      return;
    }

    // Replace periods with commas in the email to make it a valid Firebase key
    final userEmailKey = userEmail.replaceAll('.', ',');

    final cartRef = FirebaseDatabase.instance.ref('carts/$userEmailKey/cartItems');
    final keyToDelete = _cartKeys[index];

    try {
      await cartRef.child(keyToDelete).remove(); // Delete from Firebase
      setState(() {
        _cartItems.removeAt(index); // Remove from local list
        _cartKeys.removeAt(index); // Remove the corresponding key
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted from cart!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item!')),
      );
      print('Error deleting item: $error');
    }
  }


  double _calculateTotal() {
    double total = 0.0;
    for (final item in _cartItems) {
      total += item['price'] * item['quantity'];
    }
    final tax = total * (_taxPercentage / 100);
    return total + tax + _deliveryCharges;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(color: Colors.black),
        ), backgroundColor: Colors.transparent, // Make the background transparent to show the image
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
          : LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 450;
          return Column(
            children: [
              Expanded(
                child: _cartItems.isEmpty
                    ? Center(
                  child: Text(
                    'Your cart is empty!',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                    ),
                  ),
                )
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 700) {
                      // Mobile layout
                      return ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                item['imageUrl'].isNotEmpty
                                    ? SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Image.network(
                                    item['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                                  ),
                                )
                                    : const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Icon(Icons.broken_image),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Price: \$${item['price'].toStringAsFixed(2)}'),
                                      Text('Qty: ${item['quantity']}'),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Colors.green),
                                      onPressed: () => _updateQuantity(
                                          index, item['quantity'] + 1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove, color: Colors.red),
                                      onPressed: () => _updateQuantity(
                                          index, item['quantity'] - 1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteCartItem(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      // Tablet/Desktop layout
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                item['imageUrl'].isNotEmpty
                                    ? SizedBox(
                                  height: 100,
                                  child: Image.network(
                                    item['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                                  ),
                                )
                                    : const SizedBox(
                                  height: 100,
                                  child: Icon(Icons.broken_image),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('Price: \$${item['price'].toStringAsFixed(2)}'),
                                Text('Qty: ${item['quantity']}'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Colors.green),
                                      onPressed: () => _updateQuantity(
                                          index, item['quantity'] + 1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove, color: Colors.red),
                                      onPressed: () => _updateQuantity(
                                          index, item['quantity'] - 1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteCartItem(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),


              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subtotal: \$${_cartItems.fold(0.0, (sum, item) => sum + ((item['price'] ?? 0.0) * (item['quantity'] ?? 1))).toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tax (15%): \$${(_cartItems.fold(0.0, (sum, item) => sum + ((item['price'] ?? 0.0) * (item['quantity'] ?? 1))) * (_taxPercentage / 100)).toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Delivery Charges: \$$_deliveryCharges',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Text(
                      'Total: \$${_calculateTotal().toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckoutPage(cartItems: _cartItems),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: Center(
                        child: Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
