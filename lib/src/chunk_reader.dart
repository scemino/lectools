import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class Chunk {
  RandomAccessFile file;
  final int offset;
  final int size;
  final int type;

  Chunk(this.file, this.offset, this.size, this.type);

  String get typeText {
    final c1 = (type & 0x00FF);
    final c2 = (type & 0xFF00) >> 8;
    return utf8.decode([c1, c2]);
  }

  @override
  String toString() {
    return 'type=$typeText, off=$offset, size=$size';
  }

  Future<Uint8List> readData() async {
    await file.setPosition(offset + 6);
    final data = await file.read(size - 6);
    return data;
  }
}

class ChunkElement {
  ChunkReader reader;
  Chunk chunk;

  ChunkElement(this.reader, this.chunk);

  Stream<ChunkElement> elements({String name, int offset = 0}) async* {
    await reader.file.setPosition(chunk.offset + offset + 6);
    yield* reader.elements(name);
  }

  List<ChunkElement> elementsSync({String name, int offset = 0}) {
    reader.file.setPositionSync(chunk.offset + offset + 6);
    return reader.elementsSync(name);
  }

  Future<ChunkElement> element(String name) async {
    await reader.file.setPosition(chunk.offset + 6);
    return reader.element(name);
  }

  ChunkElement elementSync(String name) {
    reader.file.setPositionSync(chunk.offset + 6);
    return reader.elementSync(name);
  }

  @override
  String toString() {
    return chunk.toString();
  }
}

class ChunkReader {
  RandomAccessFile file;

  ChunkReader(this.file);

  Stream<ChunkElement> elements([String name]) async* {
    final length = await file.length();
    var offset = await file.position();
    do {
      final bytes = await file.read(6);
      final data = ByteData.sublistView(bytes);
      final size = data.getUint32(0, Endian.little);
      final type = data.getUint16(4, Endian.little);
      await file.setPosition(offset + size);
      final chunk = Chunk(file, offset, size, type);
      if (name == null || chunk.typeText == name) {
        yield ChunkElement(this, chunk);
      }
      offset += size;
    } while (offset < length);
  }

  List<ChunkElement> elementsSync([String name]) {
    final length = file.lengthSync();
    var offset = file.positionSync();
    var elements = <ChunkElement>[];
    do {
      final bytes = file.readSync(6);
      final data = ByteData.sublistView(bytes);
      final size = data.getUint32(0, Endian.little);
      final type = data.getUint16(4, Endian.little);
      file.setPositionSync(offset + size);
      final chunk = Chunk(file, offset, size, type);
      if (name == null || chunk.typeText == name) {
        elements.add(ChunkElement(this, chunk));
      }
      offset += size;
    } while (offset < length);
    return elements;
  }

  Future<ChunkElement> element(String name) async {
    return elements(name).first;
  }

  ChunkElement elementSync(String name) {
    return elementsSync(name).first;
  }
}
