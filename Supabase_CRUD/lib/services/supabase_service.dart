import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  /// Create a new user row in `users` table.
  static Future<List<dynamic>> createUser(String name, String email) async {
    final response = await _client.from('users').insert({
      'name': name,
      'email': email,
    }).select();
    return response as List<dynamic>;
  }

  /// Retrieve all users.
  static Future<List<dynamic>> getUsers() async {
    final response = await _client
        .from('users')
        .select()
        .order('id', ascending: true);
    return response as List<dynamic>;
  }

  /// Update an existing user by id.
  static Future<List<dynamic>> updateUser(
    int id,
    String name,
    String email,
  ) async {
    final response = await _client
        .from('users')
        .update({'name': name, 'email': email})
        .eq('id', id)
        .select();
    return response as List<dynamic>;
  }

  /// Delete a user by id.
  static Future<void> deleteUser(int id) async {
    await _client.from('users').delete().eq('id', id);
  }
}
