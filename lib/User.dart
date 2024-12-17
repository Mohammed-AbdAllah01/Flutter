import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AllUsersPage extends StatefulWidget {
  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  late Future<List<Map<String, String>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchAllUsers();
  }

  Future<List<Map<String, String>>> _fetchAllUsers() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    final snapshot = await usersRef.get();

    if (snapshot.exists) {
      List<Map<String, String>> users = [];
      Map data = snapshot.value as Map;

      data.forEach((key, value) {
        users.add({
          'id': key,
          'name': value['name'] ?? 'N/A',
          'phone': value['phone'] ?? 'N/A',
        });
      });

      return users;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Colors.brown,
      ),
      body: FutureBuilder<List<Map<String, String>>>(  // Display users
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching users.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: Text(user['name'] ?? 'Unknown'),
                    subtitle: Text('Phone: ${user['phone']}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
