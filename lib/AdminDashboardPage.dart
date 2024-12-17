import 'package:ecommercestore/AddProductsPage.dart';
import 'package:ecommercestore/ManageProductsPage.dart';
import 'package:ecommercestore/OrdersPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'User.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Admin!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildAdminButton(
                context,
                'View User',
                Icons.manage_accounts,
                AllUsersPage(),
              ),const SizedBox(height: 20,),
              _buildAdminButton(
                context,
                'Add Products',
                Icons.add_circle,
                const AddProductPage(),
              ),
              const SizedBox(height: 20,),
              _buildAdminButton(
                context,
                'Manage Products',
                Icons.manage_search,
                ManageProductsPage(),
              ),
              const SizedBox(height: 20),
              _buildAdminButton(
                context,
                'View Orders',
                Icons.view_list,
                const OrdersPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.black),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        onTap: () {
          // Navigate to the respective page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
