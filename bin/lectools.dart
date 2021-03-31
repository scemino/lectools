library lfltools;

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:lectools/lectools.dart';
import 'package:path/path.dart' as path;

class ExtractCommand extends Command {
  @override
  String get name => 'extract';
  @override
  String get description => 'Extract images from LEC files.';

  ExtractCommand() {
    argParser.addOption('palette',
        allowed: ['vga', 'ega', 'bega'],
        abbr: 'p',
        help: 'Choose the palette to use for export',
        defaultsTo: 'vga');
    argParser.addOption('output',
        abbr: 'o', help: 'Choose the output directory');
  }

  @override
  void run() async {
    final fileNames = argResults?.rest;
    final mode = _parsePaletteMode(argResults['palette']);
    final outputDirectory = argResults['output'] ?? Directory.current.path;
    if (fileNames == null || fileNames.isEmpty) return;
    final inputDirectory = path.dirname(fileNames[0]);
    return LecTools.extractImages(inputDirectory, outputDirectory, mode);
  }

  PaletteMode _parsePaletteMode(String mode) {
    switch (mode) {
      case 'vga':
        return PaletteMode.Vga;
      case 'ega':
        return PaletteMode.Ega;
      case 'bega':
        return PaletteMode.BlendingEga;
    }
    throw UsageException(
        'Please specify a valid palette mode between: vga, ega, bega (EGA with blending)',
        usage);
  }
}

void main(List<String> arguments) {
  CommandRunner('lectools', 'A tool to extract room images from LEC files.')
    ..addCommand(ExtractCommand())
    ..run(arguments).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64); // Exit code 64 indicates a usage error.
    });
}
