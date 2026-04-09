class TaskAssignee {
  final String id;
  final String name;
  final String department;

  const TaskAssignee({
    required this.id,
    required this.name,
    required this.department,
  });

  factory TaskAssignee.fromJson(Map<String, dynamic> json) {
    final firstName = (json['First_Name'] ?? '').toString().trim();
    final lastName = (json['Last_Name'] ?? '').toString().trim();
    final fullName = [firstName, lastName]
        .where((part) => part.isNotEmpty)
        .join(' ');

    return TaskAssignee(
      id: (json['id'] ?? '').toString(),
      name: fullName.isEmpty ? 'Unknown' : fullName,
      department: (json['Department'] ?? '').toString(),
    );
  }
}

class TaskDepartment {
  final String id;
  final String name;

  const TaskDepartment({required this.id, required this.name});

  factory TaskDepartment.fromJson(Map<String, dynamic> json) {
    return TaskDepartment(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class TaskCategory {
  final String id;
  final String name;
  final String color;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.color,
  });

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
    );
  }
}
