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

    test('Read Property from Array', () {
      Map<String, dynamic> data = {
        "MODULES": [
          {"module": "v1_module", "loader": "v1_loader"},
          {"module": "v2_module", "loader": "v2_loader"},
          {"module": "v3_module", "loader": "v3_loader"},
        ]
      };
      dynamic item = data.property("MODULES[module=v1_module]");
      assert(item != null);
    });

    test('Delete Property from Array', () {
      Map<String, dynamic> data = {
        "MODULES": [
          {"module": "v1_module", "loader": "v1_loader"},
          {"module": "v2_module", "loader": "v2_loader"},
          {"module": "v3_module", "loader": "v3_loader"},
        ]
      };
      data.removeProperty("MODULES[module=v1_module]");
      List<dynamic> item = data.property("MODULES");
      assert(item.length == 2);
    });
    test('Delete Multiple matching property from Array', () {
      Map<String, dynamic> data = {
        "MODULES": [
          {"module": "v1_module", "loader": "v1_loader"},
          {"module": "v1_module", "loader": "v2_loader"},
          {"module": "v3_module", "loader": "v3_loader"},
        ]
      };
      data.removeProperty("MODULES[module=v1_module]");
      List<dynamic> item = data.property("MODULES");
      assert(item.length == 1);
    });

    test('Delete index property from Array', () {
      Map<String, dynamic> data = {
        "MODULES": [
          {"module": "v1_module", "loader": "v1_loader"},
          {"module": "v2_module", "loader": "v2_loader"},
          {"module": "v3_module", "loader": "v3_loader"},
        ]
      };
      data.removeProperty("MODULES[1]");
      List<dynamic> item = data.property("MODULES");
      assert(item.length == 2);
    });

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

    test('Delete Property List[Index].property', () {
      Map<String, dynamic> data = {
        "values": [
          {"row": "v1", "val": "v11"},
          {"row": "v2", "val": "v22"},
          {"row": "v3", "val": "v33"}
        ]
      };
      dynamic propertyVal = data.property("values[1].row");
      assert(propertyVal is String);
      String propertyString = propertyVal;
      assert(propertyString == "v2");
      data.removeProperty("values[1].row");
      var obj = data.property("values[1]");
      dynamic pv2 = data.property("values[1].row");
      assert(pv2 == null);
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

    test('Null Read Property', () {
      Map<String, dynamic> data = {"values": "Item"};
      dynamic propertyVal = data.property("item");
      assert(propertyVal == null);
    });

    test('Null Read Sub Item', () {
      Map<String, dynamic> data = {"values": "Item"};
      dynamic propertyVal = data.property("item.value");
      assert(propertyVal == null);
    });

    test('Null Read Sub Item 2', () {
      Map<String, dynamic> data = {
        "values": "Item",
        "item": {"v": "Val1"}
      };
      dynamic propertyVal = data.property("item.value");
      assert(propertyVal == null);
    });

    test('Null Read Sub Item 3', () {
      Map<String, dynamic> data = {
        "values": "Item",
        "item": [
          {"v": "Val1"}
        ]
      };
      dynamic propertyVal = data.property("item.value");
      assert(propertyVal == null);
    });

    test('Write Replacement array', () {
      Map<String, dynamic> data = {
        "values": "Item",
        "item": [
          {"v": "Val1"}
        ]
      };
      data.setProperty("item", [
        {"v": "Val2"}
      ]);

      var itemArray = data.property("item");
      assert(itemArray is List);
      List<dynamic> ary = itemArray;
      assert(ary.length == 1);

      var itemProperty = data.property("item.v");
      assert(itemProperty == "Val2");
    });

    test('Write Sub array', () {
      Map<String, dynamic> data = {
        "values": "Item",
        "item": [
          {
            "v": "Val1",
          },
          {
            "v": "Val2",
            "children": [
              {
                "item": "V1",
              },
              {
                "item": "V2",
                "properties": {"p1": "Hello"}
              }
            ],
          }
        ]
      };
      var initialItemValue = data.property("item[1].children[1].properties.p1");
      assert(initialItemValue == "Hello");
      data.setProperty("item[1].children[1].properties.p1", "V3");
      var finalItemValue = data.property("item[1].children[1].properties.p1");
      assert(finalItemValue == "V3");
    });
  });
}
