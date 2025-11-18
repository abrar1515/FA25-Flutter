import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ReadUsersScreen extends StatefulWidget {
  const ReadUsersScreen({super.key});

  @override
  State<ReadUsersScreen> createState() => _ReadUsersScreenState();
}

class _ReadUsersScreenState extends State<ReadUsersScreen> {
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = SupabaseService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Read Users')),
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['name'] ?? 'No name'),
                subtitle: Text(user['email'] ?? 'No email'),
                trailing: Text('ID: ${user['id']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _usersFuture = SupabaseService.getUsers();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
