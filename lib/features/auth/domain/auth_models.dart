enum DashboardStyle { grid, cards, timeline }

class VantageUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final String? jobTitle;
  final String? photoUrl;
  final double? monthlySavingsGoal;
  final DashboardStyle dashboardStyle;
  final double? salaryAmount; // Importe de nómina
  final int? salaryDay; // Día del mes de cobro (1-31)
  final String actionModeId; // FK a ContextActionMode (manual, suggested, automatic)
  final bool notificationsEnabled; // Notificaciones de cambio de entorno

  VantageUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.jobTitle,
    this.photoUrl,
    this.monthlySavingsGoal,
    this.dashboardStyle = DashboardStyle.cards,
    this.salaryAmount,
    this.salaryDay,
    this.actionModeId = 'suggested', // Por defecto Sugerido
    this.notificationsEnabled = true,
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

  VantageUser copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? jobTitle,
    double? monthlySavingsGoal,
    DashboardStyle? dashboardStyle,
  }) {
    return VantageUser(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      jobTitle: jobTitle ?? this.jobTitle,
      photoUrl: photoUrl,
      monthlySavingsGoal: monthlySavingsGoal ?? this.monthlySavingsGoal,
      dashboardStyle: dashboardStyle ?? this.dashboardStyle,
    );
  }
}
