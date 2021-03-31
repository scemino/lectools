import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as path;

import 'index.dart';
import 'lec_file.dart';
import 'palette.dart';
import 'room.dart';

enum PaletteMode { Vga, Ega, BlendingEga }

class LecTools {
  static Future extractImages(
      String inputDirectory, String outputDirectory, PaletteMode mode) async {
    final indexPath = path.join(inputDirectory, '000.lfl');
    final roomNames = await Index(indexPath).readRoomsName();
    await Directory(outputDirectory).create();

    // read disks
    var colors = <int>{};
    for (var i = 1; i <= 8; i++) {
      final diskPath = path.join(inputDirectory, 'DISK0$i.LEC');
      await for (var room in LecFile(diskPath).readRooms()) {
        await Directory(outputDirectory).create(recursive: true);
        final outputPath =
            path.join(outputDirectory, '${roomNames[room.id]}.png');
        saveImage(room, outputPath, mode);
      }
    }
    print(colors);
    print('len: ${colors.length}');
  }

  static void saveImage(Room room, String name, PaletteMode mode) {
    if (room.pixels == null) return;

    switch (mode) {
      case PaletteMode.Vga:
        _saveVgaImage(room, name);
        break;
      case PaletteMode.Ega:
        _saveEgaImage(room, name);
        break;
      case PaletteMode.BlendingEga:
        _saveBlendingEgaImage(room, name);
        break;
    }
  }

  static void _saveVgaImage(Room room, String name) {
    if (room.pixels == null) return;

    final vga = room.palette;
    final rgbs = room.pixels.expand((e) {
      final i = e * 3;
      return [vga.getUint8(i), vga.getUint8(i + 1), vga.getUint8(i + 2)];
    }).toList();

    final img = Image.fromBytes(room.width, room.height, rgbs,
        format: Format.rgb, channels: Channels.rgb);
    File(name).writeAsBytesSync(encodePng(img));
    print('$name created.');
  }

  static void _saveBlendingEgaImage(Room room, String name) {
    if (room.pixels == null) return;

    final ega = room.ega;
    final rgbs = <int>[];

    var i = 0;
    for (var h = 0; h < room.height; h++) {
      final line = <int>[];
      final odd = h % 2 == 1;
      for (var w = 0; w < room.width; w++) {
        final p = room.pixels[i++];
        final e = ega.getUint8(p);
        line.addAll(_getRgbFromBlendingEga(e, odd));
      }
      rgbs.addAll(line);
    }
    // final rgbs = room.pixels.expand((e) {
    //   return getRgb(ega.getUint8(e));
    // }).toList();

    final img = Image.fromBytes(room.width, room.height, rgbs,
        format: Format.rgb, channels: Channels.rgb);
    File(name).writeAsBytesSync(encodePng(img));
    print('$name created.');
  }

  static void _saveEgaImage(Room room, String name) {
    if (room.pixels == null) return;

    final ega = room.ega;
    final rgbs = <int>[];

    var i = 0;
    for (var h = 0; h < room.height; h++) {
      final line = <int>[];
      final odd = h % 2 == 1;
      for (var w = 0; w < room.width; w++) {
        final p = room.pixels[i++];
        final e = ega.getUint8(p);
        line.addAll(_getRgbFromEga(e, odd));
      }
      rgbs.addAll(line);
      rgbs.addAll(line);
    }

    final img = Image.fromBytes(room.width * 2, room.height * 2, rgbs,
        format: Format.rgb, channels: Channels.rgb);
    File(name).writeAsBytesSync(encodePng(img));
    print('$name created.');
  }

  static List<int> _getRgbFromEga(int ega, bool odd) {
    final rgb = Palette.Ega[ega % 16];
    final r = (rgb >> 16) & 255;
    final g = (rgb >> 8) & 255;
    final b = rgb & 255;
    final rgb2 = Palette.Ega[ega ~/ 16];
    final r2 = (rgb2 >> 16) & 255;
    final g2 = (rgb2 >> 8) & 255;
    final b2 = rgb2 & 255;
    return odd ? [r, g, b, r2, g2, b2] : [r2, g2, b2, r, g, b];
  }

  static List<int> _getRgbFromBlendingEga(int ega, bool odd) {
    final rgb = Palette.Ega[ega % 16];
    final r = (rgb >> 16) & 255;
    final g = (rgb >> 8) & 255;
    final b = rgb & 255;
    final rgb2 = Palette.Ega[ega ~/ 16];
    final r2 = (rgb2 >> 16) & 255;
    final g2 = (rgb2 >> 8) & 255;
    final b2 = rgb2 & 255;
    return [(r + r2) ~/ 2, (g + g2) ~/ 2, (b + b2 ~/ 2)];
  }
}
