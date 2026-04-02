import 'dart:convert';
import 'dart:io';

class DiscoveryService {
  static const int udpPort = 4444;
  RawDatagramSocket? _socket;
  bool _isBroadcasting = false;

  // RECEIVER: Broadcast presence
  Future<void> startBroadcasting(String deviceName, String ip) async {
    _isBroadcasting = true;
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _socket!.broadcastEnabled = true;

    final message = utf8.encode("OFFLINE_SHARE_RECEIVER:$ip:4040:$deviceName");
    
    while (_isBroadcasting) {
      _socket!.send(message, InternetAddress("255.255.255.255"), udpPort);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void stopBroadcasting() {
    _isBroadcasting = false;
    _socket?.close();
    _socket = null;
  }

  // SENDER: Scan for receivers
  Future<void> startScanning(Function(String name, String ip) onDeviceFound) async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, udpPort);
    
    _socket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final dg = _socket!.receive();
        if (dg != null) {
          final message = utf8.decode(dg.data);
          if (message.startsWith("OFFLINE_SHARE_RECEIVER:")) {
            final parts = message.split(":");
            if (parts.length >= 4) {
              final ip = parts[1];
              final name = parts[3];
              onDeviceFound(name, ip);
            }
          }
        }
      }
    });
  }

  void stopScanning() {
    _socket?.close();
    _socket = null;
  }
}
