import 'dart:io';

import 'chunk_reader.dart';
import 'room.dart';
import 'room_reader.dart';
import 'xor_random_access_file.dart';

class LecFile {
  final File _file;

  LecFile(String lecPath) : _file = File(lecPath);

  Stream<Room> readRooms() async* {
    final rndAFile = await _file.open();
    final xorFile = XorRandomAccessFile(rndAFile, 0x69);
    final reader = ChunkReader(xorFile);

    final le = await reader.element('LE');
    final lfs = await le.elements(name: 'LF').toList();

    final roomReader = RoomReader();
    for (var lf in lfs) {
      final room = await roomReader.readRoom(lf);
      yield room;
    }
  }
}
