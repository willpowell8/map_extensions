library map_extension;

import 'dart:core';

import 'package:map_extension/propertyCondition.dart';

/// <p>See the full unit test suite to explore all the key uses and behaviours
/// <p>supported by this class
/// <p>See test/map_extension.dart
/// <p>There are loads of sneaky things you can use this for when reading the config object
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
    for (var i = 0; i < parts.length; i++) {
      String part = parts[i];
      if (part.contains("[")) {
        // if there is a square bracket
        List<String> subParts =
            part.split("["); // get if there is a square bracket present
        String mainPart = subParts[0]; // this is the initial piece
        if (val is List<dynamic> && val != null) {
          List<dynamic> lVal = val;
          List<dynamic> output = [];
          lVal.forEach((lItem) {
            if (lItem is Map<String, dynamic>) {
              Map<String, dynamic> mItem = lItem;
              List<String> targetParts = [];
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
          dynamic valMain = valMap[mainPart];

          String secondPart = subParts[1].replaceAll("]", "");
          if (valMain is List) {
            List<dynamic> valList = valMain;
            List<PropertyCondition> conditions = [];
            if (secondPart.contains(",") || secondPart.contains("=")) {
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
                  List<String> conditionPieces = conditonString.split("=");
                  PropertyCondition condition = PropertyCondition(
                      condition: PropertyConditionType.equal,
                      field: conditionPieces[0],
                      value: conditionPieces[1]);
                  conditions.add(condition);
                }
              });
              bool hasFoundMatch = false;
              List<dynamic> newVals = [];
              for (var i = 0; i < valList.length; i++) {
                Map<String, dynamic> valItem = valList[i];
                bool checkedValue =
                    checkObjectAgainstConditions(valItem, conditions);
                if (checkedValue == true) {
                  newVals.add(valItem);
                  valMain = valItem;
                  hasFoundMatch = true;
                }
              }
              if (hasFoundMatch == false) {
                return null;
              }
              val = newVals;
            } else if (int.tryParse(secondPart) != null) {
              /// This is when the given path contains an index
              /// i.e `create.language.selection[1]`
              int index = int.parse(secondPart);
              if (index < valList.length) {
                val = valList[index];
              } else {
                return null;
              }
            }
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else {
        if (val is Map) {
          Map<String, dynamic> valObject = val;
          if (valObject != null && valObject[part] != null) {
            val = valObject[part];
          } else {
            return null;
          }
        } else if (val is List) {
          List<dynamic> valList = val;
          List<dynamic> output = valList.map((e) {
            return DataMapUtils.propertyOnMap(e, part);
          }).toList();
          if (output.length == 1) {
            val = output.first;
          } else {
            val = output;
          }
        } else {
          val = null;
        }
      }
    }
    ;
    return val;
  }

  // check if a test object works with conditions
  static bool checkObjectAgainstConditions(
      Map<String, dynamic> testObject, List<PropertyCondition> conditions) {
    for (var i = 0; i < conditions.length; i++) {
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
            List<PropertyCondition> conditions = [];
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
              if (object is List) {
                valList = object;
              } else {
                valList.add(object);
              }
            } else {
              for (var i = 0; i < valList.length; i++) {
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
              if (valMap[part] is List && !(object is List)) {
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
          int secondPartInt;
          try {
            secondPartInt = int.parse(secondPart);
          } catch (e) {}
          if (secondPartInt != null) {
            if (isLastPart) {
              if (valList.length > secondPartInt) {
                valList.removeAt(secondPartInt);
              } else {
                return false;
              }
            } else {
              if (valList.length > secondPartInt) {
                val = valList[secondPartInt];
              } else {
                return false;
              }
            }
          } else {
            List<PropertyCondition> conditions = [];
            List<String> conditionsString = secondPart.split(",");
            conditionsString.forEach((conditionString) {
              if (conditionString.contains("!=")) {
                List<String> conditionPieces = conditionString.split("!=");
                PropertyCondition condition = PropertyCondition(
                    condition: PropertyConditionType.notEqual,
                    field: conditionPieces[0],
                    value: conditionPieces[1]);
                conditions.add(condition);
              } else if (conditionString.contains("=")) {
                List<String> conditionPieces = conditionString.split("=");
                PropertyCondition condition = PropertyCondition(
                    condition: PropertyConditionType.equal,
                    field: conditionPieces[0],
                    value: conditionPieces[1]);
                conditions.add(condition);
              }
            });
            bool hasFoundMatch = false;
            if (isLastPart == true) {
              valList.removeWhere((valItem) {
                return checkObjectAgainstConditions(valItem, conditions);
              });
            } else {
              for (var i = 0; i < valList.length; i++) {
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
