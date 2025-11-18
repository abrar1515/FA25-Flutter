import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class DeleteUserScreen extends StatefulWidget {
  const DeleteUserScreen({super.key});

  @override
  State<DeleteUserScreen> createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  late Future<List<dynamic>> _usersFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = SupabaseService.getUsers();
  }

  Future<void> _deleteUser(int userId) async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.deleteUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully!')),
        );
        setState(() {
          _usersFuture = SupabaseService.getUsers();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete User')),
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
                trailing: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _deleteUser(user['id'] as int),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () {
                setState(() {
                  _usersFuture = SupabaseService.getUsers();
                });
              },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
