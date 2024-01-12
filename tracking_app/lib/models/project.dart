class Project {
  final String id;
  final String name;
  final String description;
  final String prosta;
  final DateTime? dueDate;
  List<ProjectActivity> activities;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.prosta,
    required this.dueDate,
    List<ProjectActivity>? activities,
  }) : activities = activities ?? [];
}

class ProjectActivity {
  final String id;
  final String name;
  final String status;

  ProjectActivity({
    required this.id,
    required this.name,
    required this.status,
  });
}
