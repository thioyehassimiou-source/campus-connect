/// Modèle représentant les statistiques globales du dashboard administrateur.
class AdminStatsModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalAdmins;
  final int totalCourses;
  final int totalRooms;
  final int pendingSchedules;
  final int totalAnnouncements;
  final int activeServices;
  final Map<String, int> usersByRole;

  const AdminStatsModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalAdmins,
    required this.totalCourses,
    required this.totalRooms,
    required this.pendingSchedules,
    required this.totalAnnouncements,
    required this.activeServices,
    required this.usersByRole,
  });

  int get totalUsers => totalStudents + totalTeachers + totalAdmins;

  factory AdminStatsModel.empty() => const AdminStatsModel(
        totalStudents: 0,
        totalTeachers: 0,
        totalAdmins: 0,
        totalCourses: 0,
        totalRooms: 0,
        pendingSchedules: 0,
        totalAnnouncements: 0,
        activeServices: 0,
        usersByRole: {},
      );
}
