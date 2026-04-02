class TransferFileModel {
  final String name;
  final String path;
  final int size;
  final String extension;
  final String type;
  
  // Progress tracking
  double progress = 0.0;
  String status = 'pending'; // 'pending', 'transferring', 'completed', 'error'

  TransferFileModel({
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
    required this.type,
    this.progress = 0.0,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
      'extension': extension,
      'type': type,
    };
  }

  factory TransferFileModel.fromJson(Map<String, dynamic> json) {
    return TransferFileModel(
      name: json['name'],
      path: '', // Path is determined by the receiver
      size: json['size'],
      extension: json['extension'],
      type: json['type'],
    );
  }
}
