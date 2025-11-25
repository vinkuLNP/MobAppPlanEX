class UserEntity {
  final String uid;
  final String fullName;
  final String email;
  final bool isPaid;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool darkMode;
  final bool showCreationDates;
  final bool dailySummary;
  final bool taskReminders;
  final bool overdueAlerts;
  final bool autoSave;
  final int totalNotes;
  final int totalTasks;
  final int completedTasks;

  UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.isPaid,
    this.photoUrl,
    this.createdAt,
    this.darkMode = false,
    this.showCreationDates = false,
    this.dailySummary = false,
    this.taskReminders = false,
    this.overdueAlerts = false,
    this.autoSave = false,
    this.totalNotes = 0,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  UserEntity copyWith({
    String? fullName,
    bool? isPaid,
    String? photoUrl,
    DateTime? createdAt,
    bool? darkMode,
    bool? showCreationDates,
    bool? dailySummary,
    bool? taskReminders,
    bool? overdueAlerts,
    bool? autoSave,
    int? totalNotes,
    int? totalTasks,
    int? completedTasks,
  }) {
    return UserEntity(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      isPaid: isPaid ?? this.isPaid,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      darkMode: darkMode ?? this.darkMode,
      showCreationDates: showCreationDates ?? this.showCreationDates,
      dailySummary: dailySummary ?? this.dailySummary,
      taskReminders: taskReminders ?? this.taskReminders,
      overdueAlerts: overdueAlerts ?? this.overdueAlerts,
      autoSave: autoSave ?? this.autoSave,
      totalNotes: totalNotes ?? this.totalNotes,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }
}
