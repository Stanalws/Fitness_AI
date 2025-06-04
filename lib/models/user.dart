class User {
  final String id;
  final String name;
  final int height;
  final int weight;
  final int age;
  final String gender;
  final List<String> limitations;
  final bool noContra;
  final String? goal;
  final double? lastHeartRate; 
  final int? lastSteps;

  User({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.limitations,
    required this.noContra,
    this.goal,
    this.lastHeartRate,
    this.lastSteps,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      height: (json['height'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      limitations: List<String>.from(json['limitations'] as List<dynamic>? ?? []),
      noContra: json['noContra'] as bool? ?? false,
      goal: json['goal'] as String?,
      lastHeartRate: (json['lastHeartRate'] as num?)?.toDouble(),
      lastSteps: (json['lastSteps'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'limitations': noContra ? ['no_limitations'] : limitations,
      'noContra': noContra,
      if (goal != null) 'goal': goal,
      if (lastHeartRate != null) 'lastHeartRate': lastHeartRate,
      if (lastSteps != null) 'lastSteps': lastSteps,
    };
  }

  User copyWith({
    String? name,
    int? height,
    int? weight,
    int? age,
    String? gender,
    List<String>? limitations,
    bool? noContra,
    String? goal,
    double? lastHeartRate,
    int? lastSteps,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      limitations: limitations ?? List<String>.from(this.limitations),
      noContra: noContra ?? this.noContra,
      goal: goal ?? this.goal,
      lastHeartRate: lastHeartRate ?? this.lastHeartRate,
      lastSteps: lastSteps ?? this.lastSteps,
    );
  }
}
