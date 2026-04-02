import 'package:hive/hive.dart';

part 'transfer_history_model.g.dart';

@HiveType(typeId: 0)
class TransferHistoryModel extends HiveObject {
  @HiveField(0)
  final String fileName;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  final int fileSize;

  @HiveField(3)
  final String fileType;

  @HiveField(4)
  final String fileExtension;

  @HiveField(5)
  final String status; // 'sent', 'received'

  @HiveField(6)
  final DateTime timestamp;

  TransferHistoryModel({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileType,
    required this.fileExtension,
    required this.status,
    required this.timestamp,
  });
}
