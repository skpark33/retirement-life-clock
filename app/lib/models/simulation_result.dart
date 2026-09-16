class SimulationResult {
  final String originalRetirementDate;
  final String adjustedRetirementDate;
  final int monthsUntilRetirement;
  final double currentNetWorth;
  final double adjustedMonthlySavings;
  final double projectedNetWorth;
  final double targetAssets;
  final bool isReachable;
  final double requiredMonthlySavings;
  final double shortfall;
  final double annualReturnRate;

  SimulationResult({
    required this.originalRetirementDate,
    required this.adjustedRetirementDate,
    required this.monthsUntilRetirement,
    required this.currentNetWorth,
    required this.adjustedMonthlySavings,
    required this.projectedNetWorth,
    required this.targetAssets,
    required this.isReachable,
    required this.requiredMonthlySavings,
    required this.shortfall,
    required this.annualReturnRate,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      originalRetirementDate: json['originalRetirementDate'] as String,
      adjustedRetirementDate: json['adjustedRetirementDate'] as String,
      monthsUntilRetirement: json['monthsUntilRetirement'] as int,
      currentNetWorth: (json['currentNetWorth'] as num).toDouble(),
      adjustedMonthlySavings: (json['adjustedMonthlySavings'] as num).toDouble(),
      projectedNetWorth: (json['projectedNetWorth'] as num).toDouble(),
      targetAssets: (json['targetAssets'] as num).toDouble(),
      isReachable: json['isReachable'] as bool,
      requiredMonthlySavings: (json['requiredMonthlySavings'] as num).toDouble(),
      shortfall: (json['shortfall'] as num).toDouble(),
      annualReturnRate: (json['annualReturnRate'] as num).toDouble(),
    );
  }
}
