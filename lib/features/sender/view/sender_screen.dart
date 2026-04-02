import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../controller/sender_controller.dart';
import '../../../app/theme/app_theme.dart';

class SenderScreen extends StatelessWidget {
  const SenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SenderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Files'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Obx(() => controller.isTransferring.value 
        ? _buildTransferProgress(controller)
        : Column(
            children: [
              _buildCategorySelector(controller),
              Expanded(
                child: _buildFileList(controller),
              ),
              _buildDiscoverySection(controller),
            ],
          )),
    );
  }

  Widget _buildCategorySelector(SenderController controller) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryItem(
            icon: Icons.image,
            label: 'Images',
            color: Colors.blue,
            onTap: () => controller.pickFiles(FileType.image),
          ),
          _buildCategoryItem(
            icon: Icons.video_collection,
            label: 'Videos',
            color: Colors.red,
            onTap: () => controller.pickFiles(FileType.video),
          ),
          _buildCategoryItem(
            icon: Icons.audiotrack,
            label: 'Audio',
            color: Colors.orange,
            onTap: () => controller.pickFiles(FileType.audio),
          ),
          _buildCategoryItem(
            icon: Icons.file_present,
            label: 'Files',
            color: Colors.green,
            onTap: () => controller.pickFiles(FileType.any),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(SenderController controller) {
    if (controller.selectedFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.folderOpen, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('No files selected', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.selectedFiles.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final file = controller.selectedFiles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white12,
              child: _getFileIcon(file.type),
            ),
            title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${(file.size / 1024 / 1024).toStringAsFixed(2)} MB'),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () => controller.removeFile(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscoverySection(SenderController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nearby Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: controller.startScanning, icon: const Icon(Icons.refresh, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDeviceList(controller),
        ],
      ),
    );
  }

  Widget _buildDeviceList(SenderController controller) {
    if (controller.foundDevices.isEmpty) {
      return Center(
        child: Column(
          children: [
            const RadarAnimation(),
            const SizedBox(height: 16),
            const Text('Looking for receivers...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.foundDevices.length,
        itemBuilder: (context, index) {
          final device = controller.foundDevices[index];
          return GestureDetector(
            onTap: () => controller.sendFiles(device['ip']!),
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor,
                    child: FaIcon(FontAwesomeIcons.mobileButton, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(device['name']!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransferProgress(SenderController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.paperPlane, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 32),
            Text('Sending ${controller.currentFileName.value}', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: controller.overallProgress.value,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 16),
            Text('${(controller.overallProgress.value * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon(String type) {
    switch (type) {
      case 'image': return const Icon(Icons.image, color: Colors.blue);
      case 'video': return const Icon(Icons.video_collection, color: Colors.red);
      case 'audio': return const Icon(Icons.audiotrack, color: Colors.orange);
      case 'document': return const Icon(Icons.file_present, color: Colors.green);
      default: return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }
}

class RadarAnimation extends StatefulWidget {
  const RadarAnimation({super.key});

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(150, 150),
          painter: RadarPainter(_controller.value),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;
  RadarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(1.0 - animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final radius = (size.width / 2) * ((animationValue + (i / 3)) % 1.0);
      canvas.drawCircle(center, radius, paint);
    }

    final solidPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10, solidPaint);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) => true;
}
