class RetirementPlan {
  final String id;
  final DateTime firstWorkDate;
  final DateTime retirementGoalDate;
  final double targetAssets;
  final double currentNetWorth;
  final double monthlySavings;

  RetirementPlan({
    required this.id,
    required this.firstWorkDate,
    required this.retirementGoalDate,
    required this.targetAssets,
    required this.currentNetWorth,
    this.monthlySavings = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstWorkDate': firstWorkDate.toIso8601String().split('T')[0],
      'retirementGoalDate': retirementGoalDate.toIso8601String().split('T')[0],
      'targetAssets': targetAssets,
      'currentNetWorth': currentNetWorth,
      'monthlySavings': monthlySavings,
    };
  }

  factory RetirementPlan.fromJson(Map<String, dynamic> json) {
    return RetirementPlan(
      id: json['id'] as String,
      firstWorkDate: DateTime.parse(json['firstWorkDate'] as String),
      retirementGoalDate: DateTime.parse(json['retirementGoalDate'] as String),
      targetAssets: (json['targetAssets'] as num).toDouble(),
      currentNetWorth: (json['currentNetWorth'] as num).toDouble(),
      monthlySavings: (json['monthlySavings'] as num?)?.toDouble() ?? 0,
    );
  }

  RetirementPlan copyWith({
    String? id,
    DateTime? firstWorkDate,
    DateTime? retirementGoalDate,
    double? targetAssets,
    double? currentNetWorth,
    double? monthlySavings,
  }) {
    return RetirementPlan(
      id: id ?? this.id,
      firstWorkDate: firstWorkDate ?? this.firstWorkDate,
      retirementGoalDate: retirementGoalDate ?? this.retirementGoalDate,
      targetAssets: targetAssets ?? this.targetAssets,
      currentNetWorth: currentNetWorth ?? this.currentNetWorth,
      monthlySavings: monthlySavings ?? this.monthlySavings,
    );
  }
}
