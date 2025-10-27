import 'user_profile.dart';

// Educational tip model for contextual learning
class EducationalTip {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? icon;

  const EducationalTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.icon,
  });
}

/// Repository of educational tips for tax deductions
class EducationalTips {
  static const List<EducationalTip> _usTips = [
    EducationalTip(
      id: 'business_meals',
      title: 'Business Meals',
      content: '💡 Business meals are typically 50% deductible when discussing work with clients or colleagues. Keep notes about who you met and what was discussed.',
      category: 'meals',
      icon: '🍽️',
    ),
    EducationalTip(
      id: 'home_office',
      title: 'Home Office Deductions',
      content: '💡 Home office expenses can include a portion of your rent, utilities, and internet costs. The space must be used regularly and exclusively for business.',
      category: 'office',
      icon: '🏠',
    ),
    EducationalTip(
      id: 'equipment',
      title: 'Equipment Purchases',
      content: '💡 Business equipment over \$2,500 may need to be depreciated over several years instead of deducted immediately. Consult a tax professional for large purchases.',
      category: 'equipment',
      icon: '💻',
    ),
    EducationalTip(
      id: 'mileage',
      title: 'Mileage Deduction',
      content: '💡 You can deduct business mileage at the IRS standard rate. Keep a log of business trips including date, destination, and purpose.',
      category: 'travel',
      icon: '🚗',
    ),
    EducationalTip(
      id: 'supplies',
      title: 'Office Supplies',
      content: '💡 Office supplies and materials used directly in your business are 100% deductible. This includes paper, pens, software subscriptions, and more.',
      category: 'supplies',
      icon: '📎',
    ),
    EducationalTip(
      id: 'professional_services',
      title: 'Professional Services',
      content: '💡 Fees for lawyers, accountants, consultants, and other professional services are deductible business expenses when related to your work.',
      category: 'services',
      icon: '📊',
    ),
    EducationalTip(
      id: 'education',
      title: 'Education & Training',
      content: '💡 Courses, workshops, and training that improve your current business skills are deductible. However, education for a new career generally is not.',
      category: 'education',
      icon: '📚',
    ),
    EducationalTip(
      id: 'record_keeping',
      title: 'Record Keeping',
      content: '💡 Keep receipts and records for at least 3 years. Digital copies are accepted by the IRS, making apps like this a great tool for compliance.',
      category: 'general',
      icon: '📝',
    ),
  ];

  static const List<EducationalTip> _auTips = [
    EducationalTip(
      id: 'ato_work_from_home',
      title: 'Working from Home',
      content: '💡 The ATO fixed-rate method lets you claim 67¢ per hour for home office running costs. Keep a logbook of hours worked from home.',
      category: 'office',
      icon: '🏡',
    ),
    EducationalTip(
      id: 'ato_tools',
      title: 'Tools & Equipment',
      content: '💡 Work-related tools under AUD 300 can be fully deducted upfront. Higher-cost items are depreciated over their effective life.',
      category: 'equipment',
      icon: '🛠️',
    ),
    EducationalTip(
      id: 'ato_travel',
      title: 'Work Travel Records',
      content: '💡 Keep receipts and a travel diary for interstate trips or overnight stays. Without substantiation the ATO may deny deductions.',
      category: 'travel',
      icon: '✈️',
    ),
    EducationalTip(
      id: 'ato_self_education',
      title: 'Self-Education',
      content: '💡 Courses that maintain or improve skills for your current role are deductible. The first AUD 250 is non-deductible, so track costs carefully.',
      category: 'education',
      icon: '🎓',
    ),
    EducationalTip(
      id: 'ato_uniforms',
      title: 'Uniforms & Laundry',
      content: '💡 You can claim laundry expenses for occupation-specific clothing or protective gear. Use the ATO rate of AUD 1 per load (or 50¢ for smaller loads).',
      category: 'supplies',
      icon: '👕',
    ),
    EducationalTip(
      id: 'ato_recordkeeping',
      title: 'Keep Records for 5 Years',
      content: '💡 The ATO requires you to retain evidence for 5 years. Digital scans are fine—make sure receipts stay legible.',
      category: 'general',
      icon: '📁',
    ),
    EducationalTip(
      id: 'ato_motor_vehicle',
      title: 'Motor Vehicle Expenses',
      content: '💡 Choose between the cents-per-kilometre method (up to 5,000 km) or a logbook method that tracks actual costs. Use the one that yields the higher deduction.',
      category: 'travel',
      icon: '🚘',
    ),
  ];

  static const Map<TaxCountry, List<EducationalTip>> _tipsByCountry = {
    TaxCountry.unitedStates: _usTips,
    TaxCountry.australia: _auTips,
  };

  /// Get a random tip for display
  static EducationalTip getRandomTip(TaxCountry country) {
    final tips = _tipsByCountry[country] ?? _usTips;
    return tips[DateTime.now().millisecondsSinceEpoch % tips.length];
  }

  /// Get all tips for the selected tax country
  static List<EducationalTip> forCountry(TaxCountry country) {
    return List.unmodifiable(_tipsByCountry[country] ?? _usTips);
  }

  /// Get tips by category for a specific country
  static List<EducationalTip> getTipsByCategory(TaxCountry country, String category) {
    return forCountry(country).where((tip) => tip.category == category).toList();
  }
}
