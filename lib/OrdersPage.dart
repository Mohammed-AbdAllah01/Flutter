import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  final List<String> _statuses = const <String>['Pending', 'Received'];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() async {
    final ordersRef = FirebaseDatabase.instance.ref('orders');
    try {
      final snapshot = await ordersRef.get();
      if (snapshot.exists) {
        final List<Map<String, dynamic>> loadedOrders = [];

        // Loop through each user's order in the 'orders' node
        snapshot.children.forEach((userSnapshot) {
          final orderDetailsRef = userSnapshot.child('orderdetails');

          // Loop through each order under 'orderdetails'
          orderDetailsRef.children.forEach((orderSnapshot) {
            final orderData = orderSnapshot.value as Map;

            // Only add orders with a valid 'name'
            if (orderData['name'] != null && orderData['name'].isNotEmpty) {
              // Add order to the loadedOrders list
              loadedOrders.add({
                'orderId': orderSnapshot.key, // Unique order ID
                'name': orderData['name'] ?? 'Unknown',
                'phone': orderData['phone'] ?? 'Unknown',
                'address': orderData['address'] ?? 'Unknown',
                'items': orderData['items'] ?? [],
                'status': orderData['status'] ?? 'Pending',
                'orderDate': orderData['orderDate'] ?? 'Unknown',
              });
            }
          });
        });

        setState(() {
          _orders = loadedOrders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateOrderStatus(String orderId, String status) async {
    final ordersRef = FirebaseDatabase.instance.ref('orders');

    try {
      final snapshot = await ordersRef.get();
      if (snapshot.exists) {
        for (var userSnapshot in snapshot.children) {
          final orderDetailsRef = userSnapshot.child('orderdetails');

          for (var orderSnapshot in orderDetailsRef.children) {
            if (orderSnapshot.key == orderId) {
              if (status == 'Received') {
                // Delete the order if status is 'Received'
                await orderSnapshot.ref.remove();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order deleted successfully')),
                );
              } else {
                // Update the status for other values
                await orderSnapshot.ref.update({'status': status});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order status updated to $status')),
                );
              }
              break;
            }
          }
        }

        // Reload orders after updating or deleting
        _fetchOrders();

        // Trigger rebuild by calling setState to update the UI
        setState(() {
          // The UI is rebuilt automatically after data update
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating order status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.cyanAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text('No orders available'))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];

          // Ensure the current order's status is a valid status in _statuses
          String currentStatus = order['status'];
          if (!_statuses.contains(currentStatus)) {
            currentStatus = _statuses[0];  // Default to 'Pending' if the status is invalid
          }

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(order['name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${order['phone']}'),
                  Text('Address: ${order['address']}'),
                  Text('Order Date: ${order['orderDate']}'),
                  Text('Status: ${order['status']}'),
                  const SizedBox(height: 8),
                  Text('Items:'),
                  ...((order['items'] as List<dynamic>?)
                      ?.map((item) {
                    return Text('${item['name']} x ${item['quantity']}');
                  }).toList() ??
                      [Text('No items available')]),
                ],
              ),
              trailing: DropdownButton<String>(
                value: currentStatus,  // Use the validated status here
                icon: const Icon(Icons.arrow_downward),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _updateOrderStatus(order['orderId'], newValue);
                  }
                },
                items: _statuses
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
