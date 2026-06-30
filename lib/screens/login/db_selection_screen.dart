import 'package:flutter/material.dart';
import '../../core/network/odoo_client.dart';
import '../../core/theme/app_theme.dart';
import 'login_screen.dart';

class DbSelectionScreen extends StatelessWidget {
  final OdooClient client;
  final List<String> databases;

  const DbSelectionScreen({
    super.key,
    required this.client,
    this.databases = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.storage_rounded, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Select Database',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your company database',
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
              ),
              const Spacer(),
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: databases.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.dns_outlined, color: AppTheme.primaryColor),
                        title: Text(
                          databases[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(
                                client: client,
                                database: databases[index],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
