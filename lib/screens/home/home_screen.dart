import 'package:flutter/material.dart';
import '../../core/config/screen_config.dart';
import '../../core/network/odoo_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../data/models/module_model.dart';
import '../../data/repositories/module_repository.dart';
import '../chat/channel_list_screen.dart';
import '../common/record_list_screen.dart';
import '../settings/settings_screen.dart';
import '../splash/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  final OdooClient client;
  final UserModel? user;

  const HomeScreen({super.key, required this.client, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ModuleModel> _modules = [];
  bool _loading = true;

  static const _moduleColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.brown,
  ];

  static const _moduleIcons = {
    'sale': Icons.shopping_cart_outlined,
    'crm': Icons.business_center_outlined,
    'account': Icons.receipt_long_outlined,
    'stock': Icons.inventory_2_outlined,
    'purchase': Icons.local_shipping_outlined,
    'project': Icons.assignment_outlined,
    'hr': Icons.people_outline,
    'calendar': Icons.calendar_month_outlined,
    'mail': Icons.mail_outline,
    'mrp': Icons.precision_manufacturing_outlined,
    'point_of_sale': Icons.point_of_sale_outlined,
    'website': Icons.language_outlined,
    'base': Icons.settings_outlined,
    'documents': Icons.folder_outlined,
    'note': Icons.sticky_note_2_outlined,
    'contacts': Icons.contacts_outlined,
    'event': Icons.event_outlined,
    'survey': Icons.quiz_outlined,
    'sms': Icons.sms_outlined,
    'sign': Icons.draw_outlined,
  };

  void _openModule(ModuleModel mod) {
    if (mod.name == 'mail') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelListScreen(client: widget.client),
        ),
      );
      return;
    }
    final cfg = ScreenConfig.all[mod.name];
    if (cfg != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecordListScreen(client: widget.client, config: cfg),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${mod.displayName} - Not yet available')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    try {
      final repo = ModuleRepository(widget.client);
      final modules = await repo.getInstalledApps();
      if (mounted) setState(() { _modules = modules; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _iconFor(String name) {
    return _moduleIcons[name] ?? Icons.apps_outlined;
  }

  Color _colorFor(int i) {
    return _moduleColors[i % _moduleColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERP Dreen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const ServerInputScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        (widget.user?.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
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
                            widget.user?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.user?.email ?? '',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Applications',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _modules.isEmpty
                      ? Center(
                          child: Text(
                            'No apps found',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                          itemCount: _modules.length,
                          itemBuilder: (context, i) => _buildModuleTile(i),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile(int i) {
    final mod = _modules[i];
    final color = _colorFor(i);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openModule(mod),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(mod.name), color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              mod.displayName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
