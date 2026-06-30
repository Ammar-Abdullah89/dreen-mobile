import 'package:flutter/material.dart';
import '../../core/config/screen_config.dart';
import '../../core/network/odoo_client.dart';
import '../../core/theme/app_theme.dart';
import 'record_detail_screen.dart';

class RecordListScreen extends StatefulWidget {
  final OdooClient client;
  final ScreenConfig config;

  const RecordListScreen({
    super.key,
    required this.client,
    required this.config,
  });

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final fields = ['id', 'display_name', 'name', ...widget.config.listFields];
      final data = await widget.client.searchRead(
        widget.config.model,
        fields: fields.toSet().toList(),
        domain: [],
      );
      if (mounted) {
        setState(() {
          _records = data.cast<Map<String, dynamic>>();
          _filtered = _records;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _search(String q) {
    setState(() {
      if (q.isEmpty) {
        _filtered = _records;
      } else {
        final lower = q.toLowerCase();
        _filtered = _records.where((r) {
          final name = '${r['display_name'] ?? r['name'] ?? ''}'.toLowerCase();
          for (final f in widget.config.listFields) {
            final v = r[f];
            if (v is String && v.toLowerCase().contains(lower)) return true;
          }
          return name.contains(lower);
        }).toList();
      }
    });
  }

  String _name(Map<String, dynamic> r) => r['display_name'] ?? r['name'] ?? '';

  String _sub(Map<String, dynamic> r, int idx) {
    if (idx >= widget.config.listFields.length) return '';
    final v = r[widget.config.listFields[idx]];
    if (v is String) return v;
    if (v is List && v.length > 1) return '${v[1]}';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.config.icon, size: 22),
            const SizedBox(width: 10),
            Text(widget.config.title),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search ${widget.config.title}...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchCtrl.clear(); _search(''); },
                      )
                    : null,
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (context, i) => _recordCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.config.icon, size: 72, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No ${widget.config.title.toLowerCase()} found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _recordCard(Map<String, dynamic> r) {
    final name = _name(r);
    final sub1 = _sub(r, 0);
    final sub2 = _sub(r, 1);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecordDetailScreen(
              client: widget.client,
              config: widget.config,
              recordId: r['id'],
              title: name,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: widget.config.color.withOpacity(0.12),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: widget.config.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sub1.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.fiber_manual_record, size: 6, color: Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(sub1, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    if (sub2.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          children: [
                            Icon(Icons.fiber_manual_record, size: 6, color: Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(sub2, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
