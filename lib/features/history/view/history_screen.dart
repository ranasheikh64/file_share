import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/history_service.dart';
import '../../../models/transfer_history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<TransferHistoryModel> historyList;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      historyList = HistoryService.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer History'),
        actions: [
          IconButton(
            onPressed: () async {
              await HistoryService.clearHistory();
              _loadHistory();
            },
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          ),
        ],
      ),
      body: historyList.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            itemCount: historyList.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = historyList[index];
              return _buildHistoryItem(item);
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.clock, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text('No transfer history found.', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(TransferHistoryModel item) {
    final isSent = item.status == 'sent';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          if (item.filePath.isNotEmpty) {
            OpenFilex.open(item.filePath);
          }
        },
        leading: CircleAvatar(
          backgroundColor: isSent ? Colors.blue.withOpacity(0.2) : Colors.teal.withOpacity(0.2),
          child: FaIcon(
            isSent ? FontAwesomeIcons.paperPlane : FontAwesomeIcons.download,
            size: 18,
            color: isSent ? Colors.blue : Colors.teal,
          ),
        ),
        title: Text(item.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${(item.fileSize / 1024 / 1024).toStringAsFixed(2)} MB • ${DateFormat('MMM dd, hh:mm a').format(item.timestamp)}'),
            if (!isSent) const Text('Tap to open', style: TextStyle(color: Colors.tealAccent, fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
