import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late Future<List<dynamic>> _usersFuture;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _usersFuture = SupabaseService.getUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate() && _selectedUserId != null) {
      setState(() => _isLoading = true);
      try {
        await SupabaseService.updateUser(
          _selectedUserId!,
          _nameController.text.trim(),
          _emailController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully!')),
          );
          _nameController.clear();
          _emailController.clear();
          _selectedUserId = null;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
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
            return Column(
              children: [
                DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select a user to update'),
                  value: _selectedUserId,
                  items: users.map<DropdownMenuItem<int>>((user) {
                    return DropdownMenuItem<int>(
                      value: user['id'] as int,
                      child: Text('${user['name']} (${user['email']})'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() => _selectedUserId = newValue);
                    if (newValue != null) {
                      final user = users.firstWhere((u) => u['id'] == newValue);
                      _nameController.text = user['name'] ?? '';
                      _emailController.text = user['email'] ?? '';
                    }
                  },
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading || _selectedUserId == null
                            ? null
                            : _submitUpdate,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Update User'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
