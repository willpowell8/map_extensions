import 'package:flutter_test/flutter_test.dart';
import 'package:map_extension/map_extension.dart';

void main() {
  group('MapExtension', () {
    test('Read Property - String', () {
      Map<String, dynamic> data = {"value": "result"};
      assert(data.property("value") == "result");
    });

    test('Write and Read Property', () {
      Map<String, dynamic> data = {"values": "OK"};
      data.setProperty("written", "TEST");
      assert(data["written"] == "TEST");
      String value = data.property("written");
      assert(value == "TEST");
    });

    // test('Read Property from Array', () {
    //   Map<String, dynamic> data = {
    //     "MODULES": [
    //       {"module": "v1_module", "loader": "v1_loader"},
    //       {"module": "v2_module", "loader": "v2_loader"},
    //       {"module": "v3_module", "loader": "v3_loader"},
    //     ]
    //   };
    //   dynamic item = data.property("MODULES[module=v1_module)]");
    //   assert(item != null);
    // });

    test('Read Property List', () {
      Map<String, dynamic> data = {
        "values": ["v1", "v2", "v3"]
      };
      dynamic propertyVal = data.property("values");
      assert(propertyVal is List);
    });

    test('Read Property List Index', () {
      Map<String, dynamic> data = {
        "values": ["v1", "v2", "v3"]
      };
      dynamic propertyVal = data.property("values[0]");
      assert(propertyVal is String);
      String propertyString = propertyVal;
      assert(propertyString == "v1");
    });

    test('Read Property List[Index].property', () {
      Map<String, dynamic> data = {
        "values": [
          {"row": "v1"},
          {"row": "v2"},
          {"row": "v3"}
        ]
      };
      dynamic propertyVal = data.property("values[1].row");
      assert(propertyVal is String);
      String propertyString = propertyVal;
      assert(propertyString == "v2");
    });

    test('Read Property property.List[Index].property', () {
      Map<String, dynamic> data = {
        "items": {
          "values": [
            {"row": "v1"},
            {"row": "v2"},
            {"row": "v3"}
          ]
        }
      };
      dynamic propertyVal = data.property("items.values[1].row");
      assert(propertyVal is String);
      String propertyString = propertyVal;
      assert(propertyString == "v2");
    });

    test('Read Property List[Condition].property', () {
      Map<String, dynamic> data = {
        "values": [
          {"condition": "1", "row": "v1"},
          {"condition": "2", "row": "v2"},
          {"condition": "3", "row": "v3"}
        ]
      };
      dynamic propertyVal = data.property("values[condition=3].row");
      assert(propertyVal is String);
      String propertyString = propertyVal;
      assert(propertyString == "v3");
    });

    test('Read Property List[MultiMatchCondition].property', () {
      Map<String, dynamic> data = {
        "values": [
          {"condition": "1", "row": "v1"},
          {"condition": "1", "row": "v2"},
          {"condition": "3", "row": "v3"}
        ]
      };
      dynamic propertyVal = data.property("values[condition=1].row");
      assert(propertyVal is List);
      List propertyList = propertyVal;
      assert(propertyList.length == 2);
    });
    test('Read Property List[MultiMatchCondition].property', () {
      Map<String, dynamic> data = {
        "values": [
          {"condition": "1", "row": "v1"},
          {"condition": "1", "row": "v2"},
          {"condition": "3", "row": "v3"}
        ]
      };
      dynamic propertyVal = data.property("values[condition=4]");
      assert(propertyVal == null);
    });
  });
}
