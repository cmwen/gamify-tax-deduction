import 'dart:math';

class EducationalContentService {
  static final List<String> _tips = [
    "Business meals are typically 50% deductible when discussing work with clients or colleagues.",
    "Home office expenses can include a portion of your rent, utilities, and internet costs.",
    "Business equipment over \$2,500 may need to be depreciated over several years instead of deducted immediately.",
    "Keep detailed records of your business mileage. Every mile is a potential deduction!",
    "You can deduct the costs of professional development courses and subscriptions related to your industry.",
  ];

  static String getTipOfTheDay() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }
}
