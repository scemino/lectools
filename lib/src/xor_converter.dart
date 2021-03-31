import 'dart:convert';

class XorConverter extends Converter<List<int>, List<int>> {
  int byte;

  XorConverter(this.byte);

  @override
  List<int> convert(List<int> input) {
    for (var i = 0; i < input.length; i++) {
      input[i] ^= byte;
    }
    return input;
  }
}
