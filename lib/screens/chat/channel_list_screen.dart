import 'package:flutter/material.dart';
import '../../core/network/chat_client.dart';
import '../../core/network/odoo_client.dart';
import '../../core/theme/app_theme.dart';
import 'chat_screen.dart';

class ChannelListScreen extends StatefulWidget {
  final OdooClient client;
  const ChannelListScreen({super.key, required this.client});
  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  List<ChannelInfo> _channels = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final chat = ChatClient(widget.client);
      await chat.init();
      final channels = await chat.getChannels();
      if (mounted) setState(() { _channels = channels; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Discuss', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(_error!, style: TextStyle(color: Colors.grey.shade500), textAlign: TextAlign.center),
                ))
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _section(Icons.inbox_outlined, 'Inbox', Colors.blue, 'Congratulations, your inbox is empty\nNew messages appear here'),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _section(Icons.star_outline, 'Starred', Colors.orange, 'No starred conversations'),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _section(Icons.history, 'History', Colors.green, null),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('CHANNELS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1)),
                    ),
                    ..._channels.map((ch) => _channelTile(ch)),
                  ],
                ),
    );
  }

  Widget _section(IconData icon, String title, Color color, String? emptyMsg) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  if (emptyMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(emptyMsg, style: TextStyle(fontSize: 12, color: Colors.grey.shade400, height: 1.3)),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _channelTile(ChannelInfo ch) {
    final isChannel = ch.channelType == 'channel';
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(client: widget.client, channel: ch))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isChannel ? const Color(0xFF1A237E) : Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  isChannel ? '#${ch.name.isNotEmpty ? ch.name[0].toUpperCase() : 'C'}' : ch.name.isNotEmpty ? ch.name[0].toUpperCase() : '?',
                  style: TextStyle(color: isChannel ? Colors.white : Colors.teal, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isChannel ? '# ${ch.name}' : ch.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
