const List<String> receiptCategories = [
  'general',
  'business_meals',
  'home_office',
  'equipment',
  'mileage',
  'office_supplies',
  'professional_services',
];

String formatCategoryLabel(String value) {
  return value
      .split('_')
      .map(
        (segment) => segment.isEmpty
            ? segment
            : segment[0].toUpperCase() + segment.substring(1),
      )
      .join(' ');
}
