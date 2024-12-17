import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const CheckoutPage({super.key, required this.cartItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isProcessingOrder = false;

  void _placeOrder() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      // Show a message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    final databaseRef = FirebaseDatabase.instance.ref('orders');
    final customerPhone = _phoneController.text;
    final customerRef = databaseRef.child(customerPhone);

    final orderDetails = {
      'name': _nameController.text,
      'phone': customerPhone,
      'address': _addressController.text,
      'items': widget.cartItems, // Ensure cart items are passed here
      'orderDate': DateTime.now().toIso8601String(),
      'status': 'Pending', // Order status
    };

    try {
      // Add order details to Firebase under orders > customer > orderdetails
      await customerRef.child('orderdetails').push().set(orderDetails);

      // Clear the cart after the order is placed
      final cartRef = FirebaseDatabase.instance.ref('carts').child(customerPhone);
      await cartRef.child('cartItems').remove(); // Clear all items in the cart

      setState(() {
        _isProcessingOrder = false;
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Navigate back to the home page or cart page
      Navigator.pop(context); // Or navigate to another page if required
    } catch (error) {
      setState(() {
        _isProcessingOrder = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromRGBO(255, 223, 0, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',labelStyle:  const TextStyle(color: Color.fromRGBO(255, 223, 0, 1.0)),fillColor: Colors.white,filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',fillColor: Colors.white,filled: true,labelStyle:  const TextStyle(color: Color.fromRGBO(255, 223, 0, 1.0)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Shipping Address',fillColor: Colors.white,filled: true,labelStyle:  const TextStyle(color: Color.fromRGBO(255, 223, 0, 1.0)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
              ),
              const SizedBox(height: 8),
              ...widget.cartItems.map((item) {
                return ListTile(
                  leading: item['imageUrl'].isNotEmpty
                      ? Image.network(
                    item['imageUrl'],
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  )
                      : const Icon(Icons.broken_image),
                  title: Text(item['name'] ?? 'Unknown'),
                  subtitle: Text('Price: \$${item['price']} x ${item['quantity']}'),
                );
              }).toList(),
              const SizedBox(height: 32),
              _isProcessingOrder
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 223, 0, 1.0),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Center(
                  child: Text(
                    'Place Order (Cash on Delivery)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
