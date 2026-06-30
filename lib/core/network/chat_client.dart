import 'dart:async';
import 'odoo_client.dart';

String _stripHtml(String html) {
  return html
    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#039;', "'")
    .trim();
}

class ChatMessage {
  final int id;
  final String body;
  final int authorId;
  final String authorName;
  final String date;
  final bool isMine;

  ChatMessage({
    required this.id,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.date,
    required this.isMine,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, int myPartnerId) {
    final author = json['author_id'];
    final authorId = author is List ? author[0] as int : (json['author_id'] ?? 0);
    final authorName = author is List && author.length > 1 ? '${author[1]}' : 'Unknown';
    return ChatMessage(
      id: json['id'] ?? 0,
      body: _stripHtml((json['body'] ?? '').toString()),
      authorId: authorId,
      authorName: authorName,
      date: json['date'] ?? '',
      isMine: authorId == myPartnerId,
    );
  }
}

class ChannelInfo {
  final int id;
  final String name;
  final String channelType;

  ChannelInfo({required this.id, required this.name, required this.channelType});

  factory ChannelInfo.fromJson(Map<String, dynamic> json) {
    return ChannelInfo(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString(),
      channelType: (json['channel_type'] ?? 'chat').toString(),
    );
  }
}

class ChatClient {
  final OdooClient _odoo;
  int _myPartnerId = 0;
  Timer? _pollTimer;
  final StreamController<List<ChatMessage>> _controller = StreamController<List<ChatMessage>>.broadcast();
  int _lastId = 0;

  Stream<List<ChatMessage>> get onMessages => _controller.stream;

  ChatClient(this._odoo);

  Future<void> init() async {
    try {
      final data = await _odoo.searchRead('res.users',
          domain: [['id', '=', _odoo.userId]], fields: ['partner_id']);
      if (data.isNotEmpty && data.first is Map) {
        final p = (data.first as Map)['partner_id'];
        if (p is List && p.length > 1) _myPartnerId = p[0] as int;
      }
    } catch (_) {}
  }

  Future<List<ChannelInfo>> getChannels() async {
    try {
      final data = await _odoo.searchRead('mail.channel',
          domain: [['channel_partner_ids', 'in', [_myPartnerId]]],
          fields: ['name', 'channel_type']);
      if (data.isNotEmpty) {
        return data.map((e) => ChannelInfo.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    try {
      final data = await _odoo.searchRead('mail.channel',
          fields: ['name', 'channel_type'], limit: 20);
      return data.map((e) => ChannelInfo.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ChatMessage>> getMessages(int channelId, {int limit = 50}) async {
    try {
      final data = await _odoo.searchRead('mail.message',
          domain: [
            ['model', '=', 'mail.channel'],
            ['res_id', '=', channelId],
          ],
          fields: ['body', 'author_id', 'date'],
          limit: limit,
          order: 'date desc');
      final msgs = data.reversed
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>, _myPartnerId))
          .toList();
      if (msgs.isNotEmpty) _lastId = msgs.last.id;
      return msgs;
    } catch (_) {
      return [];
    }
  }

  Future<bool> sendMessage(int channelId, String body) async {
    try {
      await _odoo.callMethod('mail.channel', 'message_post',
          args: [channelId], kwargs: {'body': body, 'message_type': 'comment'});
      return true;
    } catch (_) {
      return false;
    }
  }

  void startPolling(int channelId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll(channelId));
  }

  Future<void> _poll(int channelId) async {
    try {
      final data = await _odoo.searchRead('mail.message',
          domain: [
            ['model', '=', 'mail.channel'],
            ['res_id', '=', channelId],
            ['id', '>', _lastId],
          ],
          fields: ['body', 'author_id', 'date']);
      if (data.isNotEmpty) {
        final msgs = data
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>, _myPartnerId))
            .toList();
        _lastId = msgs.last.id;
        _controller.add(msgs);
      }
    } catch (_) {}
  }

  void dispose() {
    _pollTimer?.cancel();
    _controller.close();
  }
}
