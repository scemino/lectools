import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'xor_converter.dart';

class XorRandomAccessFile extends RandomAccessFile {
  final RandomAccessFile file;
  final XorConverter _converter;

  XorRandomAccessFile(this.file, int xor) : _converter = XorConverter(xor);

  @override
  Future<void> close() {
    return file.close();
  }

  @override
  void closeSync() {
    return file.closeSync();
  }

  @override
  Future<RandomAccessFile> flush() {
    return file.flush();
  }

  @override
  void flushSync() {
    file.flushSync();
  }

  @override
  Future<int> length() {
    return file.length();
  }

  @override
  int lengthSync() {
    return file.lengthSync();
  }

  @override
  Future<RandomAccessFile> lock(
      [FileLock mode = FileLock.exclusive, int start = 0, int end = -1]) {
    return file.lock(mode, start, end);
  }

  @override
  void lockSync(
      [FileLock mode = FileLock.exclusive, int start = 0, int end = -1]) {
    return file.lockSync(mode, start, end);
  }

  @override
  String get path => file.path;

  @override
  Future<int> position() {
    return file.position();
  }

  @override
  int positionSync() {
    return file.positionSync();
  }

  @override
  Future<Uint8List> read(int count) async {
    final data = await file.read(count);
    return _converter.convert(data);
  }

  @override
  Future<int> readByte() async {
    return await file.readByte() ^ _converter.byte;
  }

  @override
  int readByteSync() {
    return file.readByteSync() ^ _converter.byte;
  }

  @override
  Future<int> readInto(List<int> buffer, [int start = 0, int end]) async {
    final len = await file.readInto(buffer, start, end);
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] ^= _converter.byte;
    }
    return len;
  }

  @override
  int readIntoSync(List<int> buffer, [int start = 0, int end]) {
    final len = file.readIntoSync(buffer, start, end);
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] ^= _converter.byte;
    }
    return len;
  }

  @override
  Uint8List readSync(int count) {
    final data = file.readSync(count);
    for (var i = 0; i < data.length; i++) {
      data[i] ^= _converter.byte;
    }
    return data;
  }

  @override
  Future<RandomAccessFile> setPosition(int position) {
    return file.setPosition(position);
  }

  @override
  void setPositionSync(int position) {
    return file.setPositionSync(position);
  }

  @override
  Future<RandomAccessFile> truncate(int length) {
    return file.truncate(length);
  }

  @override
  void truncateSync(int length) {
    return file.truncateSync(length);
  }

  @override
  Future<RandomAccessFile> unlock([int start = 0, int end = -1]) {
    return file.unlock(start, end);
  }

  @override
  void unlockSync([int start = 0, int end = -1]) {
    return file.unlockSync(start, end);
  }

  @override
  Future<RandomAccessFile> writeByte(int value) {
    return file.writeByte(value);
  }

  @override
  int writeByteSync(int value) {
    return file.writeByteSync(value);
  }

  @override
  Future<RandomAccessFile> writeFrom(List<int> buffer,
      [int start = 0, int end]) {
    return file.writeFrom(buffer, start, end);
  }

  @override
  void writeFromSync(List<int> buffer, [int start = 0, int end]) {
    file.writeFromSync(buffer, start, end);
  }

  @override
  Future<RandomAccessFile> writeString(String string,
      {Encoding encoding = utf8}) {
    return file.writeString(string, encoding: encoding);
  }

  @override
  void writeStringSync(String string, {Encoding encoding = utf8}) {
    file.writeStringSync(string, encoding: encoding);
  }
}
