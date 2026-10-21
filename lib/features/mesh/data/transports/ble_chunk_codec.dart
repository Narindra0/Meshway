import 'dart:math';
import 'dart:typed_data';

import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/utils/byte_utils.dart';

/// Découpe une trame HFT1 en écritures GATT de taille raisonnable.
abstract final class BleChunkCodec {
  static List<Uint8List> encode(
    Uint8List frame, {
    required int transferId,
    int payloadLength = MeshConstants.bleChunkPayloadLength,
  }) {
    if (frame.isEmpty) {
      throw ArgumentError.value(frame, 'frame', 'Trame vide');
    }
    if (frame.length > MeshConstants.maxPacketLength) {
      throw ArgumentError.value(frame.length, 'frame', 'Trame trop grande');
    }
    if (payloadLength <= 0 ||
        payloadLength + MeshConstants.bleChunkHeaderLength > 512) {
      throw ArgumentError.value(
        payloadLength,
        'payloadLength',
        'Taille invalide',
      );
    }
    final chunkCount = (frame.length / payloadLength).ceil();
    if (chunkCount > MeshConstants.bleMaxChunks) {
      throw StateError('Trop de chunks BLE.');
    }
    final chunks = <Uint8List>[];
    for (var index = 0; index < chunkCount; index++) {
      final start = index * payloadLength;
      final end = min(start + payloadLength, frame.length);
      final part = frame.sublist(start, end);
      final chunk = Uint8List(MeshConstants.bleChunkHeaderLength + part.length);
      chunk[0] = MeshConstants.bleChunkVersion;
      ByteUtils.writeUint16(chunk, 1, transferId);
      chunk[3] = index;
      chunk[4] = chunkCount;
      ByteUtils.writeUint16(chunk, 5, frame.length);
      chunk.setRange(MeshConstants.bleChunkHeaderLength, chunk.length, part);
      chunks.add(chunk);
    }
    return chunks;
  }
}

/// Réassemble les chunks reçus d'un pair. Les transferts sont identifiés par
/// l'identifiant 16 bits placé par l'émetteur.
final class BleChunkAssembler {
  final Map<int, _PendingTransfer> _pending = {};

  int get pendingTransfers => _pending.length;

  Uint8List? add(Uint8List chunk) {
    if (chunk.length < MeshConstants.bleChunkHeaderLength + 1) {
      throw const FormatException('Chunk BLE trop court.');
    }
    if (chunk[0] != MeshConstants.bleChunkVersion) {
      throw const FormatException('Version de chunk BLE inconnue.');
    }
    final transferId = ByteUtils.readUint16(chunk, 1);
    final index = chunk[3];
    final count = chunk[4];
    final totalLength = ByteUtils.readUint16(chunk, 5);
    if (count == 0 || index >= count) {
      throw const FormatException('Index de chunk BLE invalide.');
    }
    if (totalLength == 0 || totalLength > MeshConstants.maxPacketLength) {
      throw const FormatException('Longueur de trame BLE invalide.');
    }
    final payload = chunk.sublist(MeshConstants.bleChunkHeaderLength);
    if (payload.isEmpty) {
      throw const FormatException('Chunk BLE vide.');
    }

    final transfer = _pending.putIfAbsent(
      transferId,
      () => _PendingTransfer(count: count, totalLength: totalLength),
    );
    if (transfer.count != count || transfer.totalLength != totalLength) {
      _pending.remove(transferId);
      throw const FormatException('Transfert BLE incohérent.');
    }
    if (transfer.parts.containsKey(index)) {
      return null;
    }
    transfer.parts[index] = Uint8List.fromList(payload);
    transfer.receivedLength += payload.length;
    if (transfer.receivedLength > transfer.totalLength) {
      _pending.remove(transferId);
      throw const FormatException('Transfert BLE trop long.');
    }
    if (transfer.parts.length != transfer.count) {
      return null;
    }
    _pending.remove(transferId);
    if (transfer.receivedLength != transfer.totalLength) {
      throw const FormatException('Transfert BLE incomplet.');
    }
    final frame = Uint8List(transfer.totalLength);
    var offset = 0;
    for (var i = 0; i < transfer.count; i++) {
      final part = transfer.parts[i];
      if (part == null) {
        throw const FormatException('Chunk BLE manquant.');
      }
      frame.setRange(offset, offset + part.length, part);
      offset += part.length;
    }
    return frame;
  }

  void clear() => _pending.clear();
}

final class _PendingTransfer {
  _PendingTransfer({required this.count, required this.totalLength});

  final int count;
  final int totalLength;
  final Map<int, Uint8List> parts = {};
  int receivedLength = 0;
}
