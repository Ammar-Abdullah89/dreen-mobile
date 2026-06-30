import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class OdooClient {
  final String baseUrl;
  String? _sessionId;
  int? _userId;
  String? _db;
  String? _password;

  OdooClient(this.baseUrl);

  bool get isLoggedIn => _userId != null;
  int? get userId => _userId;
  String? get database => _db;
  String? get sessionId => _sessionId;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_sessionId != null) 'Cookie': 'session_id=$_sessionId',
      };

  Future<List<String>> listDatabases() async {
    final payload = _buildPayload(ApiConstants.serviceDb, ApiConstants.methodListDb, [false]);
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConstants.jsonRpc}'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    final data = jsonDecode(response.body);
    _checkError(data);
    return List<String>.from(data['result'] ?? []);
  }

  Future<Map<String, dynamic>> login(String db, String login, String password) async {
    _db = db;
    _password = password;

    final result = await _jsonRpcCall(ApiConstants.serviceCommon, ApiConstants.methodLogin, [
      db,
      login,
      password,
    ]);

    if (result is! int || result == 0) {
      throw OdooException({'message': 'Invalid credentials'});
    }

    _userId = result;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', baseUrl);
    await prefs.setString('db', db);
    await prefs.setString('login', login);

    return {'uid': _userId, 'session_id': _sessionId};
  }

  Future<List<dynamic>> searchRead(
    String model, {
    List<dynamic> domain = const [],
    List<String> fields = const [],
    int? limit,
    int offset = 0,
    String? order,
  }) async {
    final kwargs = <String, dynamic>{
      'fields': fields,
      'offset': offset,
    };
    if (limit != null) kwargs['limit'] = limit;
    if (order != null) kwargs['order'] = order;

    return await _executeKw(model, ApiConstants.methodSearchRead, [domain], kwargs);
  }

  Future<int> create(String model, Map<String, dynamic> values) async {
    return await _executeKw(model, ApiConstants.methodCreate, [values], {});
  }

  Future<void> write(String model, int id, Map<String, dynamic> values) async {
    await _executeKw(model, ApiConstants.methodWrite, [[id], values], {});
  }

  Future<void> unlink(String model, int id) async {
    await _executeKw(model, ApiConstants.methodUnlink, [[id]], {});
  }

  Future<dynamic> callMethod(
    String model,
    String method, {
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) async {
    return await _executeKw(model, method, args, kwargs);
  }

  Future<dynamic> _executeKw(
      String model, String method, List<dynamic> args, Map<String, dynamic> kwargs) async {
    return await _jsonRpcCall(ApiConstants.serviceObject, ApiConstants.methodExecuteKw, [
      _db,
      _userId,
      _password,
      model,
      method,
      args,
      kwargs,
    ]);
  }

  Future<dynamic> _jsonRpcCall(String service, String method, List<dynamic> args) async {
    final payload = _buildPayload(service, method, args);
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConstants.jsonRpc}'),
      headers: _headers,
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body);
    _checkError(data);

    if (_sessionId == null) {
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        final match = RegExp(r'session_id=([^;]+)').firstMatch(setCookie);
        if (match != null) _sessionId = match.group(1);
      }
    }

    return data['result'];
  }

  Map<String, dynamic> _buildPayload(String service, String method, List<dynamic> args) {
    return {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {'service': service, 'method': method, 'args': args},
      'id': Random().nextInt(100000),
    };
  }

  void _checkError(Map<String, dynamic> data) {
    if (data['error'] != null) {
      throw OdooException(data['error']);
    }
  }
}

class OdooException implements Exception {
  final Map<String, dynamic> error;
  OdooException(this.error);

  String get message =>
      error['data']?['message'] ?? error['message'] ?? 'Unknown error';

  @override
  String toString() => 'OdooError: $message';
}
