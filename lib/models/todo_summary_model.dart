class TodoSummary {
  final int pending;
  final int inProgress;
  final int completed;
  final List<dynamic> topTodos; // Ideally properly typed

  TodoSummary({
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.topTodos,
  });

  factory TodoSummary.fromJson(Map<String, dynamic> json) {
    return TodoSummary(
      pending: json['pending'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      completed: json['completed'] ?? 0,
      topTodos: json['topTodos'] ?? [],
    );
  }

  factory TodoSummary.empty() {
    return TodoSummary(pending: 0, inProgress: 0, completed: 0, topTodos: []);
  }
}
