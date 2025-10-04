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
  static const List<EducationalTip> all = [
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

  /// Get a random tip for display
  static EducationalTip getRandomTip() {
    return all[DateTime.now().millisecondsSinceEpoch % all.length];
  }

  /// Get tips by category
  static List<EducationalTip> getTipsByCategory(String category) {
    return all.where((tip) => tip.category == category).toList();
  }
}
