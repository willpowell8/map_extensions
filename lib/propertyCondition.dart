enum PropertyConditionType { equal, notEqual }

class PropertyCondition {
  PropertyConditionType condition;
  String field;
  dynamic value;

  PropertyCondition({this.condition, this.field, this.value});

  bool check(Map<String, dynamic> object) {
    dynamic actualValue = object[field];
    dynamic targetValue = value;
    if (targetValue is String) {
      String val = targetValue;
      targetValue = val.replaceAll("|", ".");
    }
    switch (condition) {
      case PropertyConditionType.equal:
        return actualValue == targetValue;
        break;
      case PropertyConditionType.notEqual:
        return actualValue != targetValue;
        break;
    }
    print("MISSING HANDLER");
    return false;
  }
}
