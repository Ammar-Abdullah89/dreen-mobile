import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/network/chat_client.dart';
import '../../core/network/odoo_client.dart';
import '../../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final OdooClient client;
  final ChannelInfo channel;
  const ChatScreen({super.key, required this.client, required this.channel});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatClient _chat;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<ChatMessage> _msgs = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() { super.initState(); _init(); }

  @override
  void dispose() { _sub?.cancel(); _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _init() async {
    _chat = ChatClient(widget.client);
    await _chat.init();
    _sub = _chat.onMessages.listen((msgs) {
      if (!mounted) return;
      setState(() => _msgs.addAll(msgs));
      _scrollDown();
    });
    _chat.startPolling(widget.channel.id);
    final msgs = await _chat.getMessages(widget.channel.id);
    if (mounted) setState(() { _msgs = msgs; _loading = false; });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  Future<void> _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    _ctrl.clear();
    await _chat.sendMessage(widget.channel.id, t);
    final msgs = await _chat.getMessages(widget.channel.id);
    if (mounted) setState(() => _msgs = msgs);
    _scrollDown();
  }

  String _time(String? date) {
    if (date == null || date.length < 16) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) { return date.substring(11, 16); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: widget.channel.channelType == 'channel' ? AppTheme.primaryColor : Colors.teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  widget.channel.channelType == 'channel' ? '#' : widget.channel.name.isNotEmpty ? widget.channel.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.channel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(widget.channel.channelType == 'channel' ? 'Channel' : 'Direct Message', style: TextStyle(fontSize: 11, color: Colors.grey.shade300)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined, size: 22), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_outlined, size: 22), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _msgs.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No messages yet', style: TextStyle(color: Colors.grey.shade500)),
                    ]))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: _msgs.length,
                      itemBuilder: (_, i) => _bubble(_msgs[i], i),
                    ),
        ),
        _inputBar(),
      ]),
    );
  }

  Widget _bubble(ChatMessage m, int i) {
    final me = m.isMine;
    final showAvatar = !me && (i == 0 || _msgs[i-1].authorId != m.authorId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!me && showAvatar)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 2),
              child: Text(m.authorName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            ),
          Row(
            mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!me) ...[
                if (showAvatar)
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                    child: Text(m.authorName.isNotEmpty ? m.authorName[0].toUpperCase() : '?', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                  )
                else
                  const SizedBox(width: 32),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: me ? const Color(0xFF1A237E) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(showAvatar ? 18 : 14),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(me ? 18 : 4),
                      bottomRight: Radius.circular(me ? 4 : 18),
                    ),
                    boxShadow: me ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: Column(
                    crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(m.body, style: TextStyle(color: me ? Colors.white : Colors.black87, fontSize: 15, height: 1.3)),
                      const SizedBox(height: 2),
                      Text(_time(m.date), style: TextStyle(fontSize: 10, color: me ? Colors.white.withOpacity(0.5) : Colors.grey.shade400)),
                    ],
                  ),
                ),
              ),
              if (me) const SizedBox(width: 8),
              if (me)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  child: Text('Me', style: TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(children: [
          Icon(Icons.attach_file_outlined, color: Colors.grey.shade500, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: Color(0xFF1A237E), shape: BoxShape.circle),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _send,
            ),
          ),
        ]),
      ),
    );
  }
}
