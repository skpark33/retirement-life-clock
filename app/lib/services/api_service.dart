import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/retirement_plan.dart';
import '../models/simulation_result.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:3000'});

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<RetirementPlan> savePlan(RetirementPlan plan) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/plans'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(plan.toJson()),
    );

    if (response.statusCode == 200) {
      return RetirementPlan.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save plan');
    }
  }

  Future<RetirementPlan?> getPlan(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/plans/$id'));
      if (response.statusCode == 200) {
        return RetirementPlan.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<SimulationResult> simulate(
    String planId, {
    double monthlySavingsDelta = 0,
    int retirementYearsDelta = 0,
    double livingCostPercentageDelta = 0,
    double annualReturnRate = 0.05,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/plans/$planId/simulate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'monthlySavingsDelta': monthlySavingsDelta,
        'retirementYearsDelta': retirementYearsDelta,
        'livingCostPercentageDelta': livingCostPercentageDelta,
        'annualReturnRate': annualReturnRate,
      }),
    );

    if (response.statusCode == 200) {
      return SimulationResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to simulate');
    }
  }
}
