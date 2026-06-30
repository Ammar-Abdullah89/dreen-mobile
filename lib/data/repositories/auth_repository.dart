import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/odoo_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final OdooClient _client;

  AuthRepository(this._client);

  Future<List<String>> listDatabases() => _client.listDatabases();

  Future<UserModel> login(String db, String login, String password) async {
    final result = await _client.login(db, login, password);
    final userData = await _client.searchRead(
      'res.users',
      fields: ['id', 'name', 'email', 'phone'],
      domain: [['id', '=', _client.userId]],
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _client.baseUrl);
    await prefs.setString('db', db);
    await prefs.setString('login', login);
    await prefs.setString('password', password);

    if (userData.isNotEmpty) {
      return UserModel.fromJson(userData.first as Map<String, dynamic>);
    }
    return UserModel(id: _client.userId!, name: login, email: login);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_url');
    await prefs.remove('db');
    await prefs.remove('login');
    await prefs.remove('password');
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString('server_url');
      final db = prefs.getString('db');
      final login = prefs.getString('login');
      final password = prefs.getString('password');

      if (serverUrl != null && db != null && login != null && password != null) {
        await _client.login(db, login, password);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
