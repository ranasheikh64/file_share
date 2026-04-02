import 'package:get/get.dart';
import '../../../services/socket_service.dart';
import '../../../services/discovery_service.dart';
import '../../../services/native_connection_service.dart';
import '../../../services/history_service.dart';
import '../../../models/transfer_history_model.dart';

class ReceiverController extends GetxController {
  final SocketService _socketService = SocketService();
  final DiscoveryService _discoveryService = DiscoveryService();
  final NativeConnectionService _nativeService = NativeConnectionService();

  RxString ipAddress = "".obs;
  RxString status = "Waiting...".obs;
  RxDouble progress = 0.0.obs;
  RxString currentFileName = "".obs;
  RxBool isReceiving = false.obs;

  // Native Hotspot Info
  RxString hotspotSsid = "".obs;
  RxString hotspotPassword = "".obs;
  RxBool isHotspotRunning = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupNativeHotspotListener();
    startServer();
  }

  void _setupNativeHotspotListener() {
    _nativeService.hotspotStream.listen((data) {
      hotspotSsid.value = data['ssid'] ?? 'Unknown';
      hotspotPassword.value = data['password'] ?? '';
      isHotspotRunning.value = true;
      status.value = "Hotspot Active: ${hotspotSsid.value}";
    });
  }

  Future<void> startNativeHotspot() async {
    final success = await _nativeService.startHotspot();
    if (!success) {
      Get.snackbar("Hotspot Error", "Failed to start native hotspot.");
    }
  }

  Future<void> stopNativeHotspot() async {
    await _nativeService.stopHotspot();
    isHotspotRunning.value = false;
    hotspotSsid.value = "";
    hotspotPassword.value = "";
    status.value = "Waiting...";
  }

  Future<void> startServer() async {
    final ip = await _socketService.startServer(
      onProgress: (name, p) {
        isReceiving.value = true;
        currentFileName.value = name;
        progress.value = p;
        status.value = "Receiving $name";
      },
      onFileReceived: (path, file) {
        HistoryService.addHistory(TransferHistoryModel(
          fileName: file.name,
          filePath: path,
          fileSize: file.size,
          fileType: file.type,
          fileExtension: file.extension,
          status: 'received',
          timestamp: DateTime.now(),
        ));
      },
      onError: (err) {
        Get.snackbar("Error", err);
      },
    );

    if (ip != null) {
      ipAddress.value = ip;
      final deviceName = await _nativeService.getDeviceName();
      _discoveryService.startBroadcasting(deviceName, ip);
    }
  }

  void stopServer() {
    _socketService.stopServer();
    _discoveryService.stopBroadcasting();
    if (isHotspotRunning.value) {
      stopNativeHotspot();
    }
  }

  @override
  void onClose() {
    stopServer();
    super.onClose();
  }
}
