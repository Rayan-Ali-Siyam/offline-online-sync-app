import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:offline_online_sync_app/databases/app_database.dart';
import 'package:offline_online_sync_app/models/user.dart';

class ApiService {
  final String _baseUrl = "https://652b9742d0d1df5273ee7f0a.mockapi.io";

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse("$_baseUrl/users"));

    if (response.statusCode == 200) {
      // If server returns a 200 OK response, parse the JSON
      // final jsonString = json.decode(response.body);
      return usersFromJson(response.body);
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load data from the API');
    }
  }

  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/users"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) {
      AppDatabase.instance.updateUser(
        user,
      );

      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create data on the server');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    final response = await http.put(
      Uri.parse("$_baseUrl/users/${updatedUser.id}"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedUser.toJson()),
    );

    if (response.statusCode == 200) {
      debugPrint("Successful");
    } else {
      throw Exception('Failed to update data on the server');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/users/$id'));
    response.body;
    if (response.statusCode != 200) {
      throw Exception('Failed to delete data on the server');
    }
  }

  Future<void> syncWithLocal() async {
    List<User> usersUnsynced =
        await AppDatabase.instance.readAllUsersUnsynced();

    for (User userUnsynced in usersUnsynced) {
      await createUser(userUnsynced.copy(isSynced: true));
    }
  }
}
