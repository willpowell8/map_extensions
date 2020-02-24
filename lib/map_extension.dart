library map_extension;

import 'package:map_extension/PropertyCondition.dart';

extension ExtensionMap on Map<String, dynamic> {
  Object property(String name) {
    return DataMapUtils.propertyOnMap(this, name);
  }

  bool checkObjectAgainstConditions(
      Map<String, dynamic> testObject, List<PropertyCondition> conditions) {
    return DataMapUtils.checkObjectAgainstConditions(this, conditions);
  }

  Object setProperty(String name, dynamic object) {
    return DataMapUtils.setPropertyOnMap(this, name, object);
  }

  void removeProperty(String name) {
    return DataMapUtils.removePropertyOnMap(this, name);
  }
}

class DataMapUtils {
  static Object propertyOnMap(Object map, String name) {
    if (name == null) {
      return null;
    }
    List<String> parts = name.split(".");
    Object val = map;
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      if (part.contains("[")) {
        // if there is a square bracket
        List<String> subParts =
        part.split("["); // get if there is a square bracket presentt
        String mainPart = subParts[0]; // this is the initial piece
        if (val is List<dynamic> && val != null) {
          List<dynamic> lVal = val;
          List<dynamic> output = List<dynamic>();
          lVal.forEach((lItem) {
            if (lItem is Map<String, dynamic>) {
              Map<String, dynamic> mItem = lItem;
              List<String> targetParts = List<String>();
              for (int j = i; j < parts.length; j++) {
                targetParts.add(parts[j]);
              }
              String subPart = targetParts.join(".");
              dynamic match = DataMapUtils.propertyOnMap(mItem, subPart);
              if (match != null) {
                output.add(match);
              }
            }
          });
          if (output.length > 1) {
            return output;
          } else if (output.length == 1) {
            return output[0];
          } else {
            return null;
          }
        } else if (val is Map<String, dynamic> && val != null) {
          Map<String, dynamic> valMap = val;
          val = valMap[mainPart];

          String secondPart = subParts[1].replaceAll("]", "");
          if (val is List) {
            List<dynamic> valList = val;
            List<PropertyCondition> conditions = List<PropertyCondition>();
            List<String> conditionsString = secondPart.split(",");
            conditionsString.forEach((conditonString) {
              if (conditonString.contains("!=")) {
                List<String> conditonPieces = conditonString.split("!=");
                PropertyCondition condition = PropertyCondition(
                    condition: PropertyConditionType.notEqual,
                    field: conditonPieces[0],
                    value: conditonPieces[1]);
                conditions.add(condition);
              } else if (conditonString.contains("=")) {
                List<String> conditonPieces = conditonString.split("=");
                PropertyCondition condition = PropertyCondition(
                    condition: PropertyConditionType.equal,
                    field: conditonPieces[0],
                    value: conditonPieces[1]);
                conditions.add(condition);
              }
            });
            bool hasFoundMatch = false;
            for (int i = 0; i < valList.length; i++) {
              Map<String, dynamic> valItem = valList[i];
              bool checkedValue =
              checkObjectAgainstConditions(valItem, conditions);
              if (checkedValue == true) {
                val = valItem;
                hasFoundMatch = true;
              }
            }
            if (hasFoundMatch == false) {
              return null;
            }
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else {
        Map<String, dynamic> valObject = val;
        if (valObject != null && valObject[part] != null) {
          val = valObject[part];
        } else {
          return null;
        }
      }
    }
    ;
    return val;
  }

  // check if a test object works with conditions
  static bool checkObjectAgainstConditions(
      Map<String, dynamic> testObject, List<PropertyCondition> conditions) {
    for (int i = 0; i < conditions.length; i++) {
      PropertyCondition condition = conditions[i];
      bool conditionOutput = condition.check(testObject);
      if (conditionOutput == false) {
        return false;
      }
    }
    return true;
  }

  static Object setPropertyOnMap(
      Object targetItem, String name, dynamic object) {
    List<String> parts = name.split(".");
    Object val = targetItem;
    for (int m = 0; m < parts.length; m++) {
      String part = parts[m];
      bool isLastPart = m == parts.length - 1;
      if (part.contains("[")) {
        // if there is a square bracket
        List<String> subParts =
        part.split("["); // get if there is a square bracket presentt
        String mainPart = subParts[0]; // this is the initial piece
        Map<String, dynamic> valMap = val;
        if (valMap != null) {
          val = valMap[mainPart];
          String secondPart = subParts[1].replaceAll("]", "");
          if (val is List) {
            List<dynamic> valList = val;
            List<PropertyCondition> conditions = List<PropertyCondition>();
            List<String> conditionsString = secondPart.split(",");
            conditionsString.forEach((conditonString) {
              if (conditonString.contains("!=")) {
                List<String> conditonPieces = conditonString.split("!=");
                PropertyCondition condition = PropertyCondition(
                    condition: PropertyConditionType.notEqual,
                    field: conditonPieces[0],
                    value: conditonPieces[1]);
                conditions.add(condition);
              } else if (conditonString.contains("=")) {
                List<String> conditonPieces = conditonString.split("=");
                PropertyCondition condition = PropertyCondition(
                    condition: PropertyConditionType.equal,
                    field: conditonPieces[0],
                    value: conditonPieces[1]);
                conditions.add(condition);
              }
            });
            bool hasFoundMatch = false;
            if (isLastPart == true) {
              valList.add(object);
            } else {
              for (int i = 0; i < valList.length; i++) {
                Map<String, dynamic> valItem = valList[i];
                bool checkedValue =
                checkObjectAgainstConditions(valItem, conditions);
                if (checkedValue == true) {
                  val = valItem;
                  hasFoundMatch = true;
                }
              }
              if (hasFoundMatch == false) {
                return targetItem;
              }
            }
          } else {
            return targetItem;
          }
        } else {
          return targetItem;
        }
      } else {
        if (val is Map<String, dynamic>) {
          Map<String, dynamic> valMap = val;
          if (valMap[part] != null) {
            if (isLastPart == true) {
              if (valMap[part] is List) {
                List<dynamic> partList = valMap[part];
                partList.add(object);
              } else {
                valMap[part] = object;
              }
            } else {
              val = valMap[part];
            }
          } else {
            if (isLastPart == true) {
              valMap[part] = object;
            } else {
              valMap[part] = Map<String, dynamic>();
              val = valMap[part];
            }
          }
        }
      }
    }
    ;
    return targetItem;
  }

  static removePropertyOnMap(Object map, String name) {
    List<String> parts = name.split(".");
    Object val = map;
    for (int m = 0; m < parts.length; m++) {
      String part = parts[m];
      bool isLastPart = m == parts.length - 1;
      if (part.contains("[")) {
        // if there is a square bracket
        List<String> subParts =
        part.split("["); // get if there is a square bracket presentt
        String mainPart = subParts[0]; // this is the initial piece
        Map<String, dynamic> valMap = val;
        val = valMap[mainPart];
        String secondPart = subParts[1].replaceAll("]", "");
        if (val is List) {
          List<dynamic> valList = val;
          List<PropertyCondition> conditions = List<PropertyCondition>();
          List<String> conditionsString = secondPart.split(",");
          conditionsString.forEach((conditonString) {
            if (conditonString.contains("!=")) {
              List<String> conditonPieces = conditonString.split("!=");
              PropertyCondition condition = PropertyCondition(
                  condition: PropertyConditionType.notEqual,
                  field: conditonPieces[0],
                  value: conditonPieces[1]);
              conditions.add(condition);
            } else if (conditonString.contains("=")) {
              List<String> conditonPieces = conditonString.split("=");
              PropertyCondition condition = PropertyCondition(
                  condition: PropertyConditionType.equal,
                  field: conditonPieces[0],
                  value: conditonPieces[1]);
              conditions.add(condition);
            }
          });
          bool hasFoundMatch = false;
          if (isLastPart == true) {
            valList.removeWhere((valItem) {
              return checkObjectAgainstConditions(valItem, conditions);
            });
          } else {
            for (int i = 0; i < valList.length; i++) {
              Map<String, dynamic> valItem = valList[i];
              bool checkedValue =
              checkObjectAgainstConditions(valItem, conditions);
              if (checkedValue == true) {
                val = valItem;
                hasFoundMatch = true;
              }
            }
            if (hasFoundMatch == false) {
              return false;
            }
          }
        } else {
          return false;
        }
      } else if (val is Map<String, dynamic>) {
        Map<String, dynamic> valMap = val;
        if (valMap[part] != null) {
          if (isLastPart == true) {
            valMap.remove(part);
          } else {
            val = valMap[part];
          }
        }
      } else {
        return false;
      }
    }
    ;
    return true;
  }
}
