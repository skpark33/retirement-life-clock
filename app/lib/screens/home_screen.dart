import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_provider.dart';
import '../models/retirement_plan.dart';
import '../services/storage_service.dart';
import 'scenario_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  RetirementPlan? _plan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final plan = await _storageService.loadPlan();
    setState(() {
      _plan = plan;
      _isLoading = false;
    });

    if (plan == null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  double _calculateCareerProgress() {
    if (_plan == null) return 0;
    final now = DateTime.now();
    final totalDays = _plan!.retirementGoalDate.difference(_plan!.firstWorkDate).inDays;
    final passedDays = now.difference(_plan!.firstWorkDate).inDays;
    return (passedDays / totalDays * 100).clamp(0, 100);
  }

  double _calculateAssetProgress() {
    if (_plan == null) return 0;
    return (_plan!.currentNetWorth / _plan!.targetAssets * 100).clamp(0, 100);
  }

  int _getDaysUntilRetirement() {
    if (_plan == null) return 0;
    final now = DateTime.now();
    return _plan!.retirementGoalDate.difference(now).inDays.clamp(0, 999999);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  Widget _buildProgressCard(String title, double progress, Color color, String? subtitle) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 24,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard() {
    final loc = AppLocalizations.of(context);
    final assetProgress = _calculateAssetProgress();
    
    String actionText;
    if (assetProgress >= 100) {
      actionText = loc.onTrack;
    } else if (_plan!.monthlySavings > 0) {
      final required = (_plan!.targetAssets - _plan!.currentNetWorth) / 
          (_getDaysUntilRetirement() / 30.0);
      actionText = loc.translate('monthly_savings_recommendation', 
        params: {'amount': _formatCurrency(required)});
    } else {
      actionText = loc.onTrack;
    }

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.thisMonthAction,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              actionText,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_plan == null) {
      return const SizedBox.shrink();
    }

    final careerProgress = _calculateCareerProgress();
    final assetProgress = _calculateAssetProgress();
    final daysUntilRetirement = _getDaysUntilRetirement();
    final yearsUntilRetirement = (daysUntilRetirement / 365).floor();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          IconButton(
            icon: Text(
              localeProvider.locale.languageCode == 'ko' ? 'EN' : 'KO',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              localeProvider.toggleLocale();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressCard(
              loc.careerProgress,
              careerProgress,
              Colors.purple,
              '$yearsUntilRetirement ${loc.years} (${_formatCurrency(daysUntilRetirement.toDouble())} ${loc.days})',
            ),
            const SizedBox(height: 16),
            _buildProgressCard(
              loc.assetProgress,
              assetProgress,
              Colors.green,
              '${_formatCurrency(_plan!.currentNetWorth)} / ${_formatCurrency(_plan!.targetAssets)} ${loc.won}',
            ),
            const SizedBox(height: 16),
            _buildActionCard(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScenarioScreen(plan: _plan!),
                  ),
                );
              },
              icon: const Icon(Icons.analytics),
              label: Text(loc.scenario),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
