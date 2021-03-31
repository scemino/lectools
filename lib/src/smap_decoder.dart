import 'dart:typed_data';

import 'bit_reader.dart';
import 'chunk_reader.dart';

class SmapDecoder {
  static Future<Uint8List> decodeImage(ChunkElement bm, int w, int h) async {
    var pixels = Uint8List(w * h);
    var dst = ByteData.sublistView(pixels);
    final bmData = ByteData.sublistView(await bm.chunk.readData());
    final numStrips = w ~/ 8;
    for (var i = 0; i < numStrips; i++) {
      final stripOffset = bmData.getUint32(4 + i * 4, Endian.little);
      // read strip
      final id = bmData.getUint8(stripOffset);
      final src = ByteData.sublistView(bmData, stripOffset + 1);
      switch (id) {
        case 14:
        case 15:
        case 16:
        case 17:
        case 18:
          _drawStripBasicV(id, src, dst, w, h, false);
          break;
        case 24:
        case 25:
        case 26:
        case 27:
        case 28:
          _drawStripBasicH(id, src, dst, w, h, false);
          break;
        default:
          throw Exception('Invalid smap id: $id');
      }
      dst = ByteData.sublistView(dst, 8);
    }
    return pixels;
  }

  static void _drawStripBasicV(int code, ByteData src, ByteData dst,
      int dstPitch, int height, bool transpCheck) {
    var s = 0;
    var d = 0;
    var decomp_shr = code % 10;
    var decomp_mask = 0xFF >> (8 - decomp_shr);

    var vertStripNextInc = height * dstPitch - 1;
    var color = src.getUint8(s++);
    var bits = BitReader(src.getUint8(s++));
    var inc = -1;

    var x = 8;
    do {
      var h = height;
      do {
        bits.fill(() => src.getUint8(s++));
        if (!transpCheck || color != 0xFF) {
          dst.setUint8(d, color & 0xFF);
        }
        d += dstPitch;
        if (!bits.read()) {
        } else if (!bits.read()) {
          bits.fill(() => src.getUint8(s++));
          color = bits.byte & decomp_mask;
          bits.byte >>= decomp_shr;
          bits.bit -= decomp_shr;
          inc = -1;
        } else if (!bits.read()) {
          color += inc;
        } else {
          inc = -inc;
          color += inc;
        }
      } while (--h != 0);
      d -= vertStripNextInc;
    } while (--x != 0);
  }

  static void _drawStripBasicH(int code, ByteData src, ByteData dst,
      int dstPitch, int height, bool transpCheck) {
    var s = 0;
    var d = 0;
    var decomp_shr = code % 10;
    var decomp_mask = 0xFF >> (8 - decomp_shr);
    var color = src.getUint8(s++);
    var bits = BitReader(src.getUint8(s++));
    var inc = -1;

    do {
      var x = 8;
      do {
        bits.fill(() => src.getUint8(s++));
        if (!transpCheck || color != 0xFF) {
          dst.setUint8(d, color & 0xFF);
        }
        d++;
        if (!bits.read()) {
        } else if (!bits.read()) {
          bits.fill(() => src.getUint8(s++));
          color = bits.byte & decomp_mask;
          bits.byte >>= decomp_shr;
          bits.bit -= decomp_shr;
          inc = -1;
        } else if (!bits.read()) {
          color += inc;
        } else {
          inc = -inc;
          color += inc;
        }
      } while (--x != 0);
      d += dstPitch - 8;
    } while (--height != 0);
  }
}
