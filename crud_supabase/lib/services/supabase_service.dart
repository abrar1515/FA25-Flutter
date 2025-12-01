import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://ewnxgcjlmiecatxvmxnn.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bnhnY2psbWllY2F0eHZteG5uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MDQ3MjQsImV4cCI6MjA4MDA4MDcyNH0.c8EPhvRQv6j9Fdcgv0RgYem4XNjr-IYhipbEpAF5M9k';
  static const String tableName = 'items';

  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  SupabaseClient get client => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllItems() async {
    try {
      final response = await client.from(tableName).select();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<Map<String, dynamic>> getItemById(String id) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch item: $e');
    }
  }

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> data) async {
    try {
      final response = await client.from(tableName).insert([data]).select();
      return response[0];
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  Future<Map<String, dynamic>> updateItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select();
      return response[0];
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await client.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchItems(String query) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .ilike('name', '%$query%');
      return response;
    } catch (e) {
      throw Exception('Failed to search items: $e');
    }
  }
}
