import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/transfer_file_model.dart';
import '../../../services/file_service.dart';
import '../../../services/socket_service.dart';
import '../../../services/discovery_service.dart';
import '../../../services/native_connection_service.dart';
import '../../../services/history_service.dart';
import '../../../models/transfer_history_model.dart';

class SenderController extends GetxController {
  final SocketService _socketService = SocketService();
  final DiscoveryService _discoveryService = DiscoveryService();
  final NativeConnectionService _nativeService = NativeConnectionService();

  RxList<TransferFileModel> selectedFiles = <TransferFileModel>[].obs;
  RxList<Map<String, String>> foundDevices = <Map<String, String>>[].obs;
  RxDouble overallProgress = 0.0.obs;
  RxString currentFileName = "".obs;
  RxBool isScanning = false.obs;
  RxBool isTransferring = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupNativeListeners();
    startScanning();
  }

  void _setupNativeListeners() {
    _nativeService.peerStream.listen((peers) {
      for (var peer in peers) {
        if (!foundDevices.any((d) => d['address'] == peer['address'])) {
          foundDevices.add({
            'name': peer['name'] ?? 'Unknown',
            'ip': peer['address'] ?? '', // For P2P, we use the address to connect, but the Socket IP might be different
            'address': peer['address'] ?? '',
            'type': 'p2p',
          });
        }
      }
    });
  }

  void startScanning() {
    foundDevices.clear();
    isScanning.value = true;
    _discoveryService.startScanning((name, ip) {
      if (!foundDevices.any((d) => d['ip'] == ip)) {
        foundDevices.add({
          'name': name,
          'ip': ip,
          'type': 'udp',
        });
      }
    });
    _nativeService.startDiscovery();
  }

  void stopScanning() {
    isScanning.value = false;
    _discoveryService.stopScanning();
  }

  Future<void> pickFiles(FileType type) async {
    final files = await FileService.pickFiles(type: type);
    selectedFiles.addAll(files);
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
  }

  Future<void> sendFiles(String ip) async {
    if (selectedFiles.isEmpty) return;

    isTransferring.value = true;
    stopScanning();

    await _socketService.sendFiles(
      receiverIp: ip,
      files: selectedFiles,
      onProgress: (name, p) {
        currentFileName.value = name;
        overallProgress.value = p;
      },
      onFileCompleted: (name) {
        final file = selectedFiles.firstWhere((f) => f.name == name);
        HistoryService.addHistory(TransferHistoryModel(
          fileName: file.name,
          filePath: file.path,
          fileSize: file.size,
          fileType: file.type,
          fileExtension: file.extension,
          status: 'sent',
          timestamp: DateTime.now(),
        ));
      },
      onAllCompleted: (success, message) {
        isTransferring.value = false;
        if (success) {
          Get.snackbar("Success", "Files sent successfully!");
          selectedFiles.clear();
        } else {
          Get.snackbar("Error", message ?? "Transfer failed.");
        }
      },
    );
  }

  @override
  void onClose() {
    stopScanning();
    super.onClose();
  }
}
