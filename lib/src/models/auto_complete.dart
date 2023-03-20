class AutoCompleteModel {
  String? name;
  String? fclass;
  String? geometryString;

  AutoCompleteModel({this.name, this.fclass, this.geometryString});

  AutoCompleteModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fclass = json['fclass'];
    geometryString = json['geometryString'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['fclass'] = fclass;
    data['geometryString'] = geometryString;
    return data;
  }
}
