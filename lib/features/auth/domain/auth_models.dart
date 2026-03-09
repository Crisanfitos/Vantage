class VantageUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final String? jobTitle;
  final String? photoUrl;
  final double? monthlySavingsGoal;

  VantageUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.jobTitle,
    this.photoUrl,
    this.monthlySavingsGoal,
  });

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  String get fullName => '$firstName ${lastName ?? ''}'.trim();
}
