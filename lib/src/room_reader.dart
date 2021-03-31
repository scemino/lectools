import 'dart:io';
import 'dart:typed_data';

import 'chunk_reader.dart';
import 'color_cycle.dart';
import 'room.dart';
import 'smap_decoder.dart';

class RoomReader {
  Future<Room> readRoom(ChunkElement lf) async {
    final tmp = ByteData.sublistView(await lf.chunk.readData());
    final id = tmp.getUint16(0, Endian.little);
    final ro = await lf.elements(name: 'RO', offset: 2).first;

    final sp = (await ro.element('SP'));
    final egaData = await sp.chunk.readData();
    final ega = ByteData.sublistView(egaData);
    final pa = await ro.element('PA');
    final pal = ByteData.sublistView(await pa.chunk.readData(), 2);
    final hd = await ro.elements().first;
    final hdData = ByteData.sublistView(await hd.chunk.readData());
    final w = hdData.getUint16(0, Endian.little);
    final h = hdData.getUint16(2, Endian.little);
    //final numObj = hdData.getUint16(4, Endian.little);
    final bm = await ro.element('BM');
    Uint8List pixels;
    try {
      pixels = await SmapDecoder.decodeImage(bm, w, h);
    } catch (e) {
      stderr.writeln(e);
    }

    final cc = await ro.elements(name: 'CC').first;
    var cycles = <ColorCycle>[];
    if (cc != null) {
      final ccData = ByteData.sublistView(await cc.chunk.readData());
      for (var j = 0; j < 16; ++j) {
        final delay = ccData.getUint16(0, Endian.big);
        final start = ccData.getUint8(2);
        final end = ccData.getUint8(3);
        if (delay == 0 || delay == 0x0aaa || start >= end) continue;
        cycles.add(ColorCycle(16384 ~/ delay, start, end));
      }
    }

    return Room(id, w, h, pal, ega, pixels, cycles);
  }
}
