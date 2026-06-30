import 'package:flutter/material.dart';
import '../../core/config/screen_config.dart';
import '../../core/network/odoo_client.dart';
import '../../core/theme/app_theme.dart';

class RecordDetailScreen extends StatefulWidget {
  final OdooClient client;
  final ScreenConfig config;
  final dynamic recordId;
  final String title;

  const RecordDetailScreen({
    super.key,
    required this.client,
    required this.config,
    required this.recordId,
    required this.title,
  });

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  Map<String, dynamic>? _record;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final allFields = <String>['id', 'display_name', 'name'];
      for (final s in widget.config.sections) {
        for (final f in s.fields) {
          allFields.add(f.name);
        }
      }
      final records = await widget.client.searchRead(
        widget.config.model,
        fields: allFields.toSet().toList(),
        domain: [['id', '=', widget.recordId]],
      );
      if (mounted) {
        setState(() {
          _record = records.isNotEmpty ? records.first as Map<String, dynamic> : null;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  dynamic _val(String field) => _record?[field];

  String _display(dynamic v) {
    if (v == null || v == false) return '';
    if (v is String) return v;
    if (v is num) return v.toString();
    if (v is bool) return v ? 'Yes' : 'No';
    if (v is List) {
      if (v.isEmpty) return '';
      if (v.length == 2 && v[0] is int) return '${v[1]}';
      return v.join(', ');
    }
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _record == null
              ? const Center(child: Text('Record not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _headerCard(),
                    if (widget.config.actions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _actionButtons(),
                    ],
                    ...widget.config.sections.map((s) => _sectionCard(s)),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _headerCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: widget.config.color.withOpacity(0.12),
              child: Text(
                widget.title.isNotEmpty ? widget.title[0].toUpperCase() : '?',
                style: TextStyle(
                  color: widget.config.color,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.config.model,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.config.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.config.icon, size: 16, color: widget.config.color),
                  const SizedBox(width: 4),
                  Text(
                    '${_record?['id'] ?? ''}',
                    style: TextStyle(fontSize: 12, color: widget.config.color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.config.actions.map((a) {
            final v = _val(a.field);
            final enabled = v != null && v != false && v != '';
            return InkWell(
              onTap: enabled ? () => _doAction(a) : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (enabled ? widget.config.color : Colors.grey).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        a.icon,
                        size: 22,
                        color: enabled ? widget.config.color : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: enabled ? Colors.black87 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _doAction(ActionDef action) {
    final v = _display(_val(action.field));
    if (v.isEmpty && action.type != 'map') return;

    switch (action.type) {
      case 'phone':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call $v...')),
        );
      case 'email':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email $v...')),
        );
      case 'map':
        final addr = [
          _display(_val('street')),
          _display(_val('city')),
          _display(_val('state_id')),
          _display(_val('country_id')),
        ].where((s) => s.isNotEmpty).join(', ');
        if (addr.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Open map: $addr')),
          );
        }
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$v')),
        );
    }
  }

  Widget _sectionCard(SectionDef section) {
    final visibleFields = section.fields.where((f) {
      final v = _val(f.name);
      return v != null && v != false && v != '';
    }).toList();

    if (visibleFields.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(section.icon, size: 20, color: widget.config.color),
                  const SizedBox(width: 8),
                  Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.config.color,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              ...visibleFields.map((f) => _fieldRow(f)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldRow(FieldDef f) {
    final v = _display(_val(f.name));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(f.icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  v,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
