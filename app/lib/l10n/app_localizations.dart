import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ko': {
      'app_title': '은퇴 라이프 클럭',
      'onboarding_title': '은퇴 계획 설정',
      'first_work_date': '첫 근무 시작일',
      'retirement_goal_date': '은퇴 목표일',
      'target_assets': '목표 은퇴 자산',
      'current_net_worth': '현재 순자산',
      'monthly_savings': '월 저축액 (선택)',
      'next': '다음',
      'save': '저장',
      'cancel': '취소',
      'home': '홈',
      'scenario': '시나리오',
      'career_progress': '경력 진행률',
      'asset_progress': '자산 도달률',
      'days_until_retirement': '은퇴까지',
      'days': '일',
      'years': '년',
      'this_month_action': '이번 달 액션',
      'monthly_savings_recommendation': '월 {{amount}}원이면 목표일 달성',
      'on_track': '순조롭게 진행 중',
      'scenario_simulator': '시나리오 시뮬레이터',
      'monthly_savings_delta': '월 저축액 변경',
      'retirement_years_delta': '은퇴 시점 조정 (년)',
      'living_cost_delta': '생활비 변동 (%)',
      'annual_return_rate': '연간 수익률 (%)',
      'simulate': '시뮬레이션',
      'result': '결과',
      'projected_net_worth': '예상 순자산',
      'is_reachable': '목표 달성 가능',
      'yes': '예',
      'no': '아니오',
      'required_monthly_savings': '필요 월 저축액',
      'shortfall': '부족 금액',
      'won': '원',
      'step': '단계',
      'of': '/',
      'select_date': '날짜 선택',
      'loading': '로딩 중...',
      'error': '오류',
      'retry': '재시도',
      'demo_data_loaded': '데모 데이터 로드됨',
      'earlier': '앞당기기',
      'later': '늦추기',
      'increase': '증가',
      'decrease': '감소',
      'reset': '초기화',
    },
    'en': {
      'app_title': 'Retirement Life Clock',
      'onboarding_title': 'Retirement Plan Setup',
      'first_work_date': 'First Work Start Date',
      'retirement_goal_date': 'Retirement Goal Date',
      'target_assets': 'Target Retirement Assets',
      'current_net_worth': 'Current Net Worth',
      'monthly_savings': 'Monthly Savings (Optional)',
      'next': 'Next',
      'save': 'Save',
      'cancel': 'Cancel',
      'home': 'Home',
      'scenario': 'Scenario',
      'career_progress': 'Career Progress',
      'asset_progress': 'Asset Progress',
      'days_until_retirement': 'Until Retirement',
      'days': 'days',
      'years': 'years',
      'this_month_action': 'This Month Action',
      'monthly_savings_recommendation': 'Save {{amount}} per month to reach goal',
      'on_track': 'On Track',
      'scenario_simulator': 'Scenario Simulator',
      'monthly_savings_delta': 'Monthly Savings Change',
      'retirement_years_delta': 'Retirement Timing (years)',
      'living_cost_delta': 'Living Cost Change (%)',
      'annual_return_rate': 'Annual Return Rate (%)',
      'simulate': 'Simulate',
      'result': 'Result',
      'projected_net_worth': 'Projected Net Worth',
      'is_reachable': 'Goal Reachable',
      'yes': 'Yes',
      'no': 'No',
      'required_monthly_savings': 'Required Monthly Savings',
      'shortfall': 'Shortfall',
      'won': 'KRW',
      'step': 'Step',
      'of': 'of',
      'select_date': 'Select Date',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'demo_data_loaded': 'Demo Data Loaded',
      'earlier': 'Earlier',
      'later': 'Later',
      'increase': 'Increase',
      'decrease': 'Decrease',
      'reset': 'Reset',
    },
  };

  String translate(String key, {Map<String, String>? params}) {
    String text = _localizedValues[locale.languageCode]?[key] ?? key;
    
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{{$key}}', value);
      });
    }
    
    return text;
  }

  String get appTitle => translate('app_title');
  String get onboardingTitle => translate('onboarding_title');
  String get firstWorkDate => translate('first_work_date');
  String get retirementGoalDate => translate('retirement_goal_date');
  String get targetAssets => translate('target_assets');
  String get currentNetWorth => translate('current_net_worth');
  String get monthlySavings => translate('monthly_savings');
  String get next => translate('next');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get home => translate('home');
  String get scenario => translate('scenario');
  String get careerProgress => translate('career_progress');
  String get assetProgress => translate('asset_progress');
  String get daysUntilRetirement => translate('days_until_retirement');
  String get days => translate('days');
  String get years => translate('years');
  String get thisMonthAction => translate('this_month_action');
  String get onTrack => translate('on_track');
  String get scenarioSimulator => translate('scenario_simulator');
  String get monthlySavingsDelta => translate('monthly_savings_delta');
  String get retirementYearsDelta => translate('retirement_years_delta');
  String get livingCostDelta => translate('living_cost_delta');
  String get annualReturnRate => translate('annual_return_rate');
  String get simulate => translate('simulate');
  String get result => translate('result');
  String get projectedNetWorth => translate('projected_net_worth');
  String get isReachable => translate('is_reachable');
  String get yes => translate('yes');
  String get no => translate('no');
  String get requiredMonthlySavings => translate('required_monthly_savings');
  String get shortfall => translate('shortfall');
  String get won => translate('won');
  String get step => translate('step');
  String get ofText => translate('of');
  String get selectDate => translate('select_date');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get demoDataLoaded => translate('demo_data_loaded');
  String get earlier => translate('earlier');
  String get later => translate('later');
  String get increase => translate('increase');
  String get decrease => translate('decrease');
  String get reset => translate('reset');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ko', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
