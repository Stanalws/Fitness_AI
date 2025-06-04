import 'dart:convert';

class Contraindication {
  final String code;
  final String title;

  Contraindication({
    required this.code,
    required this.title,
  });

  factory Contraindication.fromJson(Map<String, dynamic> json) {
    return Contraindication(
      code: json['code'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ContraindicationGroup {
  final String groupId;
  final String groupName;
  final List<Contraindication> items;

  ContraindicationGroup({
    required this.groupId,
    required this.groupName,
    required this.items,
  });
  
  factory ContraindicationGroup.fromJson(Map<String, dynamic> json) {
    return ContraindicationGroup(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => Contraindication.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}