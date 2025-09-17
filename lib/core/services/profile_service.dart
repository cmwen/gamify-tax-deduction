import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/user_profile.dart';
import 'package:sqflite/sqflite.dart';

class ProfileService {
  final DatabaseHelper dbHelper;

  ProfileService({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<void> saveProfile(UserProfile profile) async {
    final db = await dbHelper.database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getProfile() async {
    final db = await dbHelper.database;
    // There should only ever be one user profile.
    // The UI should enforce this.
    final List<Map<String, dynamic>> maps = await db.query('user_profile', limit: 1);

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<UserProfile> getOrCreateProfile() async {
    final profile = await getProfile();
    if (profile != null) {
      return profile;
    } else {
      final newProfile = UserProfile(
        id: const Uuid().v4(),
        filingStatus: FilingStatus.single, // Default value
        incomeBracket: IncomeBracket.middle, // Default value
      );
      await saveProfile(newProfile);
      return newProfile;
    }
  }
}
