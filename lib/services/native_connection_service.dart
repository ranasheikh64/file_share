import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

class NativeConnectionService {
  static const MethodChannel _methodChannel = MethodChannel('com.antigravity.offline_share/native_connection');
  static const EventChannel _eventChannel = EventChannel('com.antigravity.offline_share/connection_events');

  final _peerController = StreamController<List<Map<String, String>>>.broadcast();
  final _connectionController = StreamController<Map<String, dynamic>>.broadcast();
  final _hotspotController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<List<Map<String, String>>> get peerStream => _peerController.stream;
  Stream<Map<String, dynamic>> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get hotspotStream => _hotspotController.stream;

  NativeConnectionService() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      final String type = event['type'];
      final dynamic data = event['data'];

      switch (type) {
        case 'peers':
          final List<Map<String, String>> peers = (data as List).map((e) => Map<String, String>.from(e)).toList();
          _peerController.add(peers);
          break;
        case 'connection':
          _connectionController.add(Map<String, dynamic>.from(data));
          break;
        case 'hotspot':
          _hotspotController.add(Map<String, dynamic>.from(data));
          break;
      }
    });
  }

  Future<bool> startDiscovery() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _methodChannel.invokeMethod('startDiscovery');
    } catch (e) {
      return false;
    }
  }

  Future<bool> stopDiscovery() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _methodChannel.invokeMethod('stopDiscovery');
    } catch (e) {
      return false;
    }
  }

  Future<bool> startHotspot() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _methodChannel.invokeMethod('startHotspot');
    } catch (e) {
      return false;
    }
  }

  Future<bool> stopHotspot() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _methodChannel.invokeMethod('stopHotspot');
    } catch (e) {
      return false;
    }
  }

  Future<String> getDeviceName() async {
    if (Platform.isAndroid) {
      try {
        return await _methodChannel.invokeMethod('getDeviceName');
      } catch (e) {
        return "Android Device";
      }
    } else if (Platform.isIOS) {
      return "iPhone";
    }
    return "Unknown Device";
  }

  void dispose() {
    _peerController.close();
    _connectionController.close();
    _hotspotController.close();
  }
}
