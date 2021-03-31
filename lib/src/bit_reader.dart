class BitReader {
  int byte;
  int bit = 8;
  BitReader(this.byte);

  bool read() {
    bit--;
    final result = byte & 1;
    byte >>= 1;
    return result == 1;
  }

  void fill(int Function() b) {
    if (bit <= 8) {
      byte |= b() << bit;
      bit += 8;
    }
  }
}
