import 'package:hive_flutter/hive_flutter.dart';
import '../models/transfer_history_model.dart';

class HistoryService {
  static const String boxName = 'transfer_history';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransferHistoryModelAdapter());
    await Hive.openBox<TransferHistoryModel>(boxName);
  }

  static Future<void> addHistory(TransferHistoryModel history) async {
    final box = Hive.box<TransferHistoryModel>(boxName);
    await box.add(history);
  }

  static List<TransferHistoryModel> getHistory() {
    final box = Hive.box<TransferHistoryModel>(boxName);
    return box.values.toList().reversed.toList();
  }

  static Future<void> clearHistory() async {
    final box = Hive.box<TransferHistoryModel>(boxName);
    await box.clear();
  }
}
