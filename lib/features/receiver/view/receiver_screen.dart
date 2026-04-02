import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/receiver_controller.dart';
import '../../../app/theme/app_theme.dart';

class ReceiverScreen extends StatelessWidget {
  const ReceiverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReceiverController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Files'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Obx(() => controller.isReceiving.value
        ? _buildReceiveProgress(controller)
        : _buildWaitingState(controller)),
    );
  }

  Widget _buildWaitingState(ReceiverController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRadarPulse(),
          const SizedBox(height: 40),
          Text(
            'Ready to Receive',
            style: Get.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan the QR code or wait for discovery',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 20),
          _buildHotspotControls(controller),
          const SizedBox(height: 20),
          if (controller.hotspotSsid.value.isNotEmpty)
            _buildHotspotInfo(controller),
          if (controller.ipAddress.value.isNotEmpty && !controller.isHotspotRunning.value)
            _buildQrCode(controller),
          const SizedBox(height: 20),
          if (controller.ipAddress.value.isNotEmpty)
            Text(
              'IP Address: ${controller.ipAddress.value}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildHotspotControls(ReceiverController controller) {
    if (Platform.isIOS) {
      return _buildIOSHotspotGuide();
    }
    return Obx(() => ElevatedButton.icon(
      onPressed: controller.isHotspotRunning.value 
        ? controller.stopNativeHotspot 
        : controller.startNativeHotspot,
      icon: Icon(controller.isHotspotRunning.value ? Icons.portable_wifi_off : Icons.wifi_tethering),
      label: Text(controller.isHotspotRunning.value ? "Stop Hotspot" : "Start Hotspot"),
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.isHotspotRunning.value ? Colors.redAccent : AppTheme.primaryColor,
      ),
    ));
  }

  Widget _buildIOSHotspotGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber),
              SizedBox(width: 12),
              Text("iOS Tip", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "To receive files on iOS, please turn on your 'Personal Hotspot' in System Settings or ensure both devices are on the same WiFi.",
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotInfo(ReceiverController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _buildInfoRow("Network", controller.hotspotSsid.value),
          const Divider(color: Colors.white12),
          _buildInfoRow("Password", controller.hotspotPassword.value),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQrCode(ReceiverController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: QrImageView(
        data: '${controller.ipAddress.value}:4040',
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildRadarPulse() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryColor.withOpacity(0.2),
      ),
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.download,
          size: 40,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildReceiveProgress(ReceiverController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.cloudDownloadAlt, size: 64, color: Colors.tealAccent),
            const SizedBox(height: 32),
            Text(
              'Receiving ${controller.currentFileName.value}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: controller.progress.value,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 16),
            Text(
              '${(controller.progress.value * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
