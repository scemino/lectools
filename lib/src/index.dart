import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'chunk_reader.dart';

class Index {
  final File _indexFile;

  Index(String indexPath) : _indexFile = File(indexPath);

  Future<Map<int, String>> readRoomsName() async {
    if (!await _indexFile.exists()) {
      throw Exception('Index $_indexFile. is missing');
    }
    final index = await _indexFile.open();
    final indexReader = ChunkReader(index);

    final rn = await indexReader.element('RN');

    final data = ByteData.sublistView(await rn.chunk.readData());
    var offset = 0;
    var nameBytes = Uint8List(8);
    var roomNames = <int, String>{};
    while (offset < data.lengthInBytes) {
      final roomNum = data.getUint8(offset);
      offset++;
      var i = 0;
      for (i = 0; i < 8 && i < data.lengthInBytes - offset; i++) {
        nameBytes[i] = data.getUint8(offset + i) ^ 0xff;
        if (nameBytes[i] == 0) break;
      }
      final name = utf8.decode(nameBytes.take(i).toList());
      roomNames[roomNum] = name;
      offset += 9;
    }
    return roomNames;
  }
}
