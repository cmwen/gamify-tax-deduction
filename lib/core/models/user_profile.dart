enum FilingStatus {
  single,
  marriedFilingJointly,
  marriedFilingSeparately,
  headOfHousehold,
  qualifyingWidow
}

enum IncomeBracket {
  lowest,
  low,
  middle,
  high,
  highest
}

enum TaxCountry {
  unitedStates,
  australia,
}

class UserProfile {
  final String id;
  final FilingStatus filingStatus;
  final IncomeBracket incomeBracket;
  final TaxCountry taxCountry;

  UserProfile({
    required this.id,
    required this.filingStatus,
    required this.incomeBracket,
    required this.taxCountry,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filingStatus': filingStatus.toString(),
      'incomeBracket': incomeBracket.toString(),
      'taxCountry': taxCountry.toString(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      filingStatus: FilingStatus.values.firstWhere((e) => e.toString() == map['filingStatus']),
      incomeBracket: IncomeBracket.values.firstWhere((e) => e.toString() == map['incomeBracket']),
      taxCountry: _parseCountry(map['taxCountry']),
    );
  }

  static TaxCountry _parseCountry(String? value) {
    if (value == null) {
      return TaxCountry.unitedStates;
    }
    return TaxCountry.values.firstWhere(
      (country) => country.toString() == value,
      orElse: () => TaxCountry.unitedStates,
    );
  }
}
