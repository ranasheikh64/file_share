// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransferHistoryModelAdapter extends TypeAdapter<TransferHistoryModel> {
  @override
  final int typeId = 0;

  @override
  TransferHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransferHistoryModel(
      fileName: fields[0] as String,
      filePath: fields[1] as String,
      fileSize: fields[2] as int,
      fileType: fields[3] as String,
      fileExtension: fields[4] as String,
      status: fields[5] as String,
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TransferHistoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.fileName)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.fileSize)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.fileExtension)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
