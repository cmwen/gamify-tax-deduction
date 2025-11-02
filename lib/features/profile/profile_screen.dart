import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/user_profile.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/theme_service.dart';

class _OptionDetail {
  final String label;
  final String description;
  const _OptionDetail({required this.label, required this.description});
}

const Map<TaxCountry, _OptionDetail> _taxCountryDetails = {
  TaxCountry.unitedStates: _OptionDetail(
    label: 'United States (IRS)',
    description: 'Choose this if you file US federal income taxes.',
  ),
  TaxCountry.australia: _OptionDetail(
    label: 'Australia (ATO)',
    description:
        'Choose this if you lodge tax returns with the Australian Taxation Office.',
  ),
};

const Map<IncomeBracket, _OptionDetail> _incomeBracketDetails = {
  IncomeBracket.lowest: _OptionDetail(
    label: 'Entry level (under ~45k)',
    description: 'Students, apprentices, or part-time earners.',
  ),
  IncomeBracket.low: _OptionDetail(
    label: 'Growing income (~45k–90k)',
    description: 'Developing careers and small businesses with modest profits.',
  ),
  IncomeBracket.middle: _OptionDetail(
    label: 'Established (~90k–170k)',
    description: 'Stable income with consistent business revenue.',
  ),
  IncomeBracket.high: _OptionDetail(
    label: 'High earner (~170k–220k)',
    description: 'Senior roles or businesses with strong profits.',
  ),
  IncomeBracket.highest: _OptionDetail(
    label: 'Top bracket (220k+)',
    description: 'High income earners likely in the top marginal rate.',
  ),
};

const Map<FilingStatus, _OptionDetail> _filingStatusDetails = {
  FilingStatus.single: _OptionDetail(
    label: 'Single',
    description: 'You lodge on your own (applies in both US and Australia).',
  ),
  FilingStatus.marriedFilingJointly: _OptionDetail(
    label: 'Married filing jointly',
    description:
        'US couples filing together. Australian couples usually select Single.',
  ),
  FilingStatus.marriedFilingSeparately: _OptionDetail(
    label: 'Married filing separately',
    description: 'US option when each spouse files on their own return.',
  ),
  FilingStatus.headOfHousehold: _OptionDetail(
    label: 'Head of household',
    description: 'US option for single filers supporting dependents.',
  ),
  FilingStatus.qualifyingWidow: _OptionDetail(
    label: 'Qualifying widow(er)',
    description: 'US option for recent widows or widowers with dependents.',
  ),
};

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
  TaxCountry? _selectedTaxCountry;

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
      _selectedTaxCountry = userProfile.taxCountry;
    });
  }

  void _saveProfile() async {
    if (_userProfile != null &&
        _selectedIncomeBracket != null &&
        _selectedFilingStatus != null &&
        _selectedTaxCountry != null) {
      final updatedProfile = UserProfile(
        id: _userProfile!.id,
        incomeBracket: _selectedIncomeBracket!,
        filingStatus: _selectedFilingStatus!,
        taxCountry: _selectedTaxCountry!,
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

  Widget _buildOptionContent(_OptionDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          detail.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          detail.description,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyLabel =
        _selectedTaxCountry == TaxCountry.australia ? 'AUD' : 'USD';
    final isAustralia = _selectedTaxCountry == TaxCountry.australia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Which tax system applies to you?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<TaxCountry>(
                      value: _selectedTaxCountry,
                      isExpanded: true,
                      hint: const Text('Select tax country'),
                      items: TaxCountry.values.map((country) {
                        final detail = _taxCountryDetails[country]!;
                        return DropdownMenuItem<TaxCountry>(
                          value: country,
                          child: _buildOptionContent(detail),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTaxCountry = newValue;
                          if (newValue == TaxCountry.australia) {
                            _selectedFilingStatus = FilingStatus.single;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'App appearance:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Consumer<ThemeService>(
                      builder: (context, themeService, _) {
                        final mode = themeService.themeMode;
                        return RadioGroup<ThemeMode>(
                          groupValue: mode,
                          onChanged: (value) {
                            if (value != null) {
                              themeService.updateThemeMode(value);
                            }
                          },
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.system,
                                title: Text('Match system'),
                              ),
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.light,
                                title: Text('Light theme'),
                              ),
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.dark,
                                title: Text('Dark theme'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select your estimated income bracket ($currencyLabel ranges):',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<IncomeBracket>(
                      value: _selectedIncomeBracket,
                      isExpanded: true,
                      hint: const Text('Select income bracket'),
                      items: IncomeBracket.values.map((value) {
                        final detail = _incomeBracketDetails[value]!;
                        return DropdownMenuItem<IncomeBracket>(
                          value: value,
                          child: _buildOptionContent(detail),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedIncomeBracket = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    if (!isAustralia) ...[
                      const Text(
                        'Select your filing status:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<FilingStatus>(
                        value: _selectedFilingStatus,
                        isExpanded: true,
                        hint: const Text('Select filing status'),
                        items: FilingStatus.values.map((value) {
                          final detail = _filingStatusDetails[value]!;
                          return DropdownMenuItem<FilingStatus>(
                            value: value,
                            child: _buildOptionContent(detail),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedFilingStatus = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      Card(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Filing status is not required for Australian tax calculations.\nWe will automatically apply the standard rate.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Disclaimer: This information is used for estimation purposes only and is not professional tax advice.',
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selectedIncomeBracket != null &&
                                _selectedFilingStatus != null &&
                                _selectedTaxCountry != null)
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
            ),
    );
  }
}
