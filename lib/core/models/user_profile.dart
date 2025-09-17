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

class UserProfile {
  final String id;
  final FilingStatus filingStatus;
  final IncomeBracket incomeBracket;

  UserProfile({
    required this.id,
    required this.filingStatus,
    required this.incomeBracket,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filingStatus': filingStatus.toString(),
      'incomeBracket': incomeBracket.toString(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      filingStatus: FilingStatus.values.firstWhere((e) => e.toString() == map['filingStatus']),
      incomeBracket: IncomeBracket.values.firstWhere((e) => e.toString() == map['incomeBracket']),
    );
  }
}
