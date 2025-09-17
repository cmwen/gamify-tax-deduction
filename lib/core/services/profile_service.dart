import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

class ProfileService {
  static const String _incomeBracketKey = 'user_income_bracket';
  static const String _filingStatusKey = 'user_filing_status';

  /// Save user profile data to local storage
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_incomeBracketKey, profile.incomeBracket);
    await prefs.setString(_filingStatusKey, profile.filingStatus);
  }

  /// Retrieve user profile data from local storage
  Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final incomeBracket = prefs.getString(_incomeBracketKey);
    final filingStatus = prefs.getString(_filingStatusKey);

    if (incomeBracket != null && filingStatus != null) {
      return UserProfile(
        incomeBracket: incomeBracket,
        filingStatus: filingStatus,
      );
    }
    return null;
  }
}
