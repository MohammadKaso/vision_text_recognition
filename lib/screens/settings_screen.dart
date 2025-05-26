import 'package:flutter/material.dart';
import '../utils/navigation_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => NavigationUtils.goBackOrHome(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('AI & Processing', [
            _buildSettingsTile(
              'OCR Confidence Threshold',
              'Minimum confidence for text recognition',
              Icons.visibility,
              onTap: () {},
            ),
            _buildSettingsTile(
              'Auto-enhance Images',
              'Automatically improve image quality',
              Icons.auto_fix_high,
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            _buildSettingsTile(
              'Speech Language',
              'Default language for voice recognition',
              Icons.language,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Data & Storage', [
            _buildSettingsTile(
              'Export Orders',
              'Export order data to CSV',
              Icons.download,
              onTap: () {},
            ),
            _buildSettingsTile(
              'Clear Cache',
              'Clear temporary files and cache',
              Icons.cleaning_services,
              onTap: () {},
            ),
            _buildSettingsTile(
              'Backup Data',
              'Backup orders to cloud storage',
              Icons.backup,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Notifications', [
            _buildSettingsTile(
              'Order Notifications',
              'Get notified about order updates',
              Icons.notifications,
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            _buildSettingsTile(
              'AI Processing Alerts',
              'Notifications for AI processing results',
              Icons.smart_toy,
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('About', [
            _buildSettingsTile(
              'App Version',
              '1.0.0',
              Icons.info,
              onTap: () {},
            ),
            _buildSettingsTile(
              'Privacy Policy',
              'View our privacy policy',
              Icons.privacy_tip,
              onTap: () {},
            ),
            _buildSettingsTile(
              'Terms of Service',
              'View terms and conditions',
              Icons.description,
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
