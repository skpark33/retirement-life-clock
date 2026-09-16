import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/retirement_plan.dart';
import '../models/simulation_result.dart';
import '../services/api_service.dart';

class ScenarioScreen extends StatefulWidget {
  final RetirementPlan plan;

  const ScenarioScreen({super.key, required this.plan});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final ApiService _apiService = ApiService();
  
  double _monthlySavingsDelta = 0;
  int _retirementYearsDelta = 0;
  double _livingCostPercentageDelta = 0;
  double _annualReturnRate = 5.0;
  
  SimulationResult? _result;
  bool _isLoading = false;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  Future<void> _runSimulation() async {
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.simulate(
        widget.plan.id,
        monthlySavingsDelta: _monthlySavingsDelta,
        retirementYearsDelta: _retirementYearsDelta,
        livingCostPercentageDelta: _livingCostPercentageDelta,
        annualReturnRate: _annualReturnRate / 100,
      );
      
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
      }
    }
  }

  Widget _buildSlider(String label, double value, double min, double max, 
      ValueChanged<double> onChanged, {String? suffix, int divisions = 100}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              '${value.toStringAsFixed(value >= 100000 ? 0 : 1)}${suffix ?? ''}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();

    final loc = AppLocalizations.of(context);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.result,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildResultRow(
              loc.isReachable,
              _result!.isReachable ? loc.yes : loc.no,
              _result!.isReachable ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            _buildResultRow(
              loc.projectedNetWorth,
              '${_formatCurrency(_result!.projectedNetWorth)} ${loc.won}',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildResultRow(
              loc.requiredMonthlySavings,
              '${_formatCurrency(_result!.requiredMonthlySavings)} ${loc.won}',
              Colors.orange,
            ),
            if (!_result!.isReachable) ...[
              const SizedBox(height: 12),
              _buildResultRow(
                loc.shortfall,
                '${_formatCurrency(_result!.shortfall)} ${loc.won}',
                Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.scenarioSimulator),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSlider(
                      loc.monthlySavingsDelta,
                      _monthlySavingsDelta,
                      -2000000,
                      2000000,
                      (value) => setState(() => _monthlySavingsDelta = value),
                      suffix: ' ${loc.won}',
                      divisions: 200,
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      loc.retirementYearsDelta,
                      _retirementYearsDelta.toDouble(),
                      -10,
                      10,
                      (value) => setState(() => _retirementYearsDelta = value.round()),
                      suffix: ' ${loc.years}',
                      divisions: 20,
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      loc.livingCostDelta,
                      _livingCostPercentageDelta,
                      -50,
                      50,
                      (value) => setState(() => _livingCostPercentageDelta = value),
                      suffix: '%',
                      divisions: 100,
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      loc.annualReturnRate,
                      _annualReturnRate,
                      0,
                      15,
                      (value) => setState(() => _annualReturnRate = value),
                      suffix: '%',
                      divisions: 150,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runSimulation,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(loc.simulate),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            if (_result != null) _buildResultCard(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _monthlySavingsDelta = 0;
                  _retirementYearsDelta = 0;
                  _livingCostPercentageDelta = 0;
                  _annualReturnRate = 5.0;
                  _result = null;
                });
              },
              child: Text(loc.reset),
            ),
          ],
        ),
      ),
    );
  }
}
