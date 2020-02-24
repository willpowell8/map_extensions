enum PropertyConditionType { equal, notEqual }

class PropertyCondition {
  PropertyConditionType condition;
  String field;
  dynamic value;

  PropertyCondition({this.condition, this.field, this.value});

  bool check(Map<String, dynamic> object) {
    dynamic actualValue = object[field];
    switch (condition) {
      case PropertyConditionType.equal:
        return actualValue == value;
        break;
      case PropertyConditionType.notEqual:
        return actualValue != value;
        break;
    }
  }
}
