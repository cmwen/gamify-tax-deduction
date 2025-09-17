import 'package:flutter/material.dart';
import '../../core/models/data_models.dart';
import '../../core/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  String? _selectedIncomeBracket;
  String? _selectedFilingStatus;

  final _incomeBrackets = ['low', 'medium', 'high'];
  final _filingStatuses = ['single', 'married'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userProfile = await _profileService.getProfile();
    if (userProfile != null) {
      setState(() {
        _selectedIncomeBracket = userProfile.incomeBracket;
        _selectedFilingStatus = userProfile.filingStatus;
      });
    }
  }

  void _saveProfile() async {
    if (_selectedIncomeBracket != null && _selectedFilingStatus != null) {
      final userProfile = UserProfile(
        incomeBracket: _selectedIncomeBracket!,
        filingStatus: _selectedFilingStatus!,
      );
      await _profileService.saveProfile(userProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your estimated income bracket:',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<String>(
              value: _selectedIncomeBracket,
              isExpanded: true,
              hint: const Text('Select Income Bracket'),
              items: _incomeBrackets.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedIncomeBracket = newValue;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Select your tax filing status:',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<String>(
              value: _selectedFilingStatus,
              isExpanded: true,
              hint: const Text('Select Filing Status'),
              items: _filingStatuses.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFilingStatus = newValue;
                });
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedIncomeBracket != null && _selectedFilingStatus != null)
                    ? _saveProfile
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
