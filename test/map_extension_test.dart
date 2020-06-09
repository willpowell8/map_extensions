import 'package:flutter_test/flutter_test.dart';
import 'package:map_extension/map_extension.dart';

void main() {
  test('adds one to input values', () {
    Map<String, dynamic> data = {"value": "result"};
    assert(data.property("value") == "result");
  });
}
