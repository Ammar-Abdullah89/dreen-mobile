import '../../core/network/odoo_client.dart';
import '../models/module_model.dart';

class ModuleRepository {
  final OdooClient _client;

  ModuleRepository(this._client);

  Future<List<ModuleModel>> getInstalledApps() async {
    final data = await _client.searchRead(
      'ir.module.module',
      domain: [
        ['state', '=', 'installed'],
        ['application', '=', true],
      ],
      fields: ['name', 'display_name', 'icon', 'summary'],
    );
    return data.map((e) => ModuleModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
