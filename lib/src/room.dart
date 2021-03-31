import 'dart:typed_data';

import 'color_cycle.dart';

class Room {
  final int id;
  final int width;
  final int height;
  final Uint8List pixels;
  final ByteData palette;
  final ByteData ega;
  final List<ColorCycle> cycles;

  Room(this.id, this.width, this.height, this.palette, this.ega, this.pixels,
      this.cycles);
}
