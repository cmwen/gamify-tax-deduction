import 'package:flutter/material.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileService? profileService;
  const ProfileScreen({super.key, this.profileService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileService _profileService;
  UserProfile? _userProfile;

  IncomeBracket? _selectedIncomeBracket;
  FilingStatus? _selectedFilingStatus;

  @override
  void initState() {
    super.initState();
    _profileService = widget.profileService ?? ProfileService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userProfile = await _profileService.getOrCreateProfile();
    setState(() {
      _userProfile = userProfile;
      _selectedIncomeBracket = userProfile.incomeBracket;
      _selectedFilingStatus = userProfile.filingStatus;
    });
  }

  void _saveProfile() async {
    if (_userProfile != null && _selectedIncomeBracket != null && _selectedFilingStatus != null) {
      final updatedProfile = UserProfile(
        id: _userProfile!.id,
        incomeBracket: _selectedIncomeBracket!,
        filingStatus: _selectedFilingStatus!,
      );
      await _profileService.saveProfile(updatedProfile);

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
      body: _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your estimated income bracket:',
                    style: TextStyle(fontSize: 16),
                  ),
                  DropdownButton<IncomeBracket>(
                    value: _selectedIncomeBracket,
                    isExpanded: true,
                    hint: const Text('Select Income Bracket'),
                    items: IncomeBracket.values.map((IncomeBracket value) {
                      return DropdownMenuItem<IncomeBracket>(
                        value: value,
                        child: Text(value.toString().split('.').last),
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
                  DropdownButton<FilingStatus>(
                    value: _selectedFilingStatus,
                    isExpanded: true,
                    hint: const Text('Select Filing Status'),
                    items: FilingStatus.values.map((FilingStatus value) {
                      return DropdownMenuItem<FilingStatus>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFilingStatus = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Disclaimer: This information is used for estimation purposes only and is not professional tax advice.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
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
