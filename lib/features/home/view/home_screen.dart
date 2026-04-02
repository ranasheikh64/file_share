import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../sender/view/sender_screen.dart';
import '../../receiver/view/receiver_screen.dart';
import '../../history/view/history_screen.dart';
import '../../../services/permission_service.dart';
import '../../../app/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Share'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const HistoryScreen()),
            icon: const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeroSection(),
            const SizedBox(height: 40),
            _buildActionButtons(),
            const SizedBox(height: 40),
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Files',
          style: Get.textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Fast, secure, and offline sharing.',
          style: Get.textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            title: 'Send',
            icon: FontAwesomeIcons.paperPlane,
            color: AppTheme.primaryColor,
            onTap: () async {
              if (await PermissionService.requestPermissions()) {
                Get.to(() => const SenderScreen());
              } else {
                Get.snackbar('Permission Denied', 'Please grant permissions to continue.');
              }
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildActionButton(
            title: 'Receive',
            icon: FontAwesomeIcons.download,
            color: Colors.tealAccent.shade700,
            onTap: () async {
              if (await PermissionService.requestPermissions()) {
                Get.to(() => const ReceiverScreen());
              } else {
                Get.snackbar('Permission Denied', 'Please grant permissions to continue.');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 40, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quick Connect', style: Get.textTheme.headlineMedium),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white12,
                child: FaIcon(FontAwesomeIcons.bolt, color: Colors.amber),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto Discovery', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Scanning for nearby devices...', style: TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              Switch(value: true, onChanged: (v) {}, activeColor: Colors.amber),
            ],
          ),
        ),
      ],
    );
  }
}
