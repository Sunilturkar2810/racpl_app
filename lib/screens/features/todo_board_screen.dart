import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../models/todo_model.dart';

class TodoBoardScreen extends StatefulWidget {
  const TodoBoardScreen({super.key});

  @override
  State<TodoBoardScreen> createState() => _TodoBoardScreenState();
}

class _TodoBoardScreenState extends State<TodoBoardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TodoProvider>().fetchTodos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Board'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error?.message ?? 'Error loading todos'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchTodos(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            children: [
              _TodoColumn(
                title: 'To Do',
                todos: provider.todoByStatus,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _TodoColumn(
                title: 'In Progress',
                todos: provider.inProgressByStatus,
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _TodoColumn(
                title: 'Done',
                todos: provider.doneByStatus,
                color: Colors.green,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create todo screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TodoColumn extends StatelessWidget {
  final String title;
  final List<Todo> todos;
  final Color color;

  const _TodoColumn({
    required this.title,
    required this.todos,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todos.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return _TodoCard(todo: todo);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final Todo todo;

  const _TodoCard({required this.todo});

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              todo.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(todo.priority).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                todo.priority,
                style: TextStyle(
                  color: _getPriorityColor(todo.priority),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
