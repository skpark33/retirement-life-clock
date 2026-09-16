import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/retirement_plan.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  DateTime? _firstWorkDate;
  DateTime? _retirementGoalDate;
  final _targetAssetsController = TextEditingController();
  final _currentNetWorthController = TextEditingController();
  final _monthlySavingsController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _targetAssetsController.dispose();
    _currentNetWorthController.dispose();
    _monthlySavingsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFirstWork) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isFirstWork) {
          _firstWorkDate = picked;
        } else {
          _retirementGoalDate = picked;
        }
      });
    }
  }

  Future<void> _savePlan() async {
    if (_firstWorkDate == null || _retirementGoalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).error)),
      );
      return;
    }

    final targetAssets = double.tryParse(_targetAssetsController.text) ?? 0;
    final currentNetWorth = double.tryParse(_currentNetWorthController.text) ?? 0;
    final monthlySavings = double.tryParse(_monthlySavingsController.text) ?? 0;

    if (targetAssets <= 0 || currentNetWorth < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).error)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final plan = RetirementPlan(
        id: 'user-plan-${DateTime.now().millisecondsSinceEpoch}',
        firstWorkDate: _firstWorkDate!,
        retirementGoalDate: _retirementGoalDate!,
        targetAssets: targetAssets,
        currentNetWorth: currentNetWorth,
        monthlySavings: monthlySavings,
      );

      await _storageService.savePlan(plan);
      
      try {
        await _apiService.savePlan(plan);
      } catch (e) {
        // API save failed, but local save succeeded
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStep1() {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.firstWorkDate,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context, true),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _firstWorkDate != null
                      ? DateFormat('yyyy-MM-dd').format(_firstWorkDate!)
                      : loc.selectDate,
                  style: TextStyle(
                    color: _firstWorkDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.retirementGoalDate,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context, false),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _retirementGoalDate != null
                      ? DateFormat('yyyy-MM-dd').format(_retirementGoalDate!)
                      : loc.selectDate,
                  style: TextStyle(
                    color: _retirementGoalDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _targetAssetsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: loc.targetAssets,
            border: const OutlineInputBorder(),
            suffixText: loc.won,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _currentNetWorthController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: loc.currentNetWorth,
            border: const OutlineInputBorder(),
            suffixText: loc.won,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _monthlySavingsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: loc.monthlySavings,
            border: const OutlineInputBorder(),
            suffixText: loc.won,
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
        title: Text(loc.onboardingTitle),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${loc.step} ${_currentStep + 1} ${loc.ofText} 3',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 32),
                  if (_currentStep == 0) _buildStep1(),
                  if (_currentStep == 1) _buildStep2(),
                  if (_currentStep == 2) _buildStep3(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: () {
                            setState(() => _currentStep--);
                          },
                          child: Text(loc.cancel),
                        )
                      else
                        const SizedBox.shrink(),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentStep < 2) {
                            if (_currentStep == 0 && _firstWorkDate == null) return;
                            if (_currentStep == 1 && _retirementGoalDate == null) return;
                            setState(() => _currentStep++);
                          } else {
                            _savePlan();
                          }
                        },
                        child: Text(_currentStep < 2 ? loc.next : loc.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
