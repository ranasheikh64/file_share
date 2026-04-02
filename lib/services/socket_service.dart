import 'dart:convert';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/transfer_file_model.dart';
import 'file_service.dart';

class SocketService {
  static const int port = 4040;
  ServerSocket? _serverSocket;

  // SENDER (Client)
  Future<void> sendFiles({
    required String receiverIp,
    required List<TransferFileModel> files,
    required Function(String fileName, double progress) onProgress,
    required Function(String fileName) onFileCompleted,
    required Function(bool success, String? message) onAllCompleted,
  }) async {
    try {
      for (var file in files) {
        final socket = await Socket.connect(receiverIp, port);
        final f = File(file.path);
        
        // 1. Send header
        final header = jsonEncode(file.toJson());
        socket.add(utf8.encode("$header\n"));

        // 2. Send file bytes
        final stream = f.openRead();
        int sentBytes = 0;

        await for (final chunk in stream) {
          socket.add(chunk);
          sentBytes += chunk.length;
          onProgress(file.name, sentBytes / file.size);
        }

        await socket.flush();
        await socket.close();
        onFileCompleted(file.name);
      }
      onAllCompleted(true, null);
    } catch (e) {
      onAllCompleted(false, e.toString());
    }
  }

  // RECEIVER (Server)
  Future<String?> startServer({
    required Function(String fileName, double progress) onProgress,
    required Function(String savedPath, TransferFileModel file) onFileReceived,
    required Function(String error) onError,
  }) async {
    try {
      final String? ip = await NetworkInfo().getWifiIP();
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      
      _serverSocket!.listen((Socket socket) async {
        try {
          String? fileName;
          int? fileSize;
          String? fileType;
          String? fileExt;
          
          final saveDir = await FileService.getSaveDirectory();
          
          List<int> buffer = [];
          bool headerParsed = false;
          IOSink? sink;
          int totalReceived = 0;

          await for (List<int> chunk in socket) {
            if (!headerParsed) {
              buffer.addAll(chunk);
              final index = buffer.indexOf(10); // \n
              if (index != -1) {
                final headerBytes = buffer.sublist(0, index);
                final header = jsonDecode(utf8.decode(headerBytes));
                
                fileName = header['name'];
                fileSize = header['size'];
                fileType = header['type'];
                fileExt = header['extension'];

                final remaining = buffer.sublist(index + 1);
                
                final savePath = "$saveDir/$fileName";
                final f = File(savePath);
                sink = f.openWrite();
                
                if (remaining.isNotEmpty) {
                  sink.add(remaining);
                  totalReceived += remaining.length;
                }
                
                headerParsed = true;
                onProgress(fileName!, totalReceived / fileSize!);
              }
            } else {
              sink!.add(chunk);
              totalReceived += chunk.length;
              onProgress(fileName!, totalReceived / fileSize!);
            }
          }

          await sink?.flush();
          await sink?.close();
          
          if (fileName != null) {
            onFileReceived(
              "$saveDir/$fileName",
              TransferFileModel(
                name: fileName,
                path: "$saveDir/$fileName",
                size: fileSize!,
                type: fileType!,
                extension: fileExt!,
                status: 'completed',
              ),
            );
          }
        } catch (e) {
          onError(e.toString());
        }
      });
      
      return ip;
    } catch (e) {
      onError(e.toString());
      return null;
    }
  }

  void stopServer() {
    _serverSocket?.close();
    _serverSocket = null;
  }
}
