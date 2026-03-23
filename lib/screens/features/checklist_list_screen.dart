import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checklist_provider.dart';
import '../../models/checklist_model.dart';

class ChecklistListScreen extends StatefulWidget {
  const ChecklistListScreen({super.key});

  @override
  State<ChecklistListScreen> createState() => _ChecklistListScreenState();
}

class _ChecklistListScreenState extends State<ChecklistListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ChecklistProvider>().fetchChecklists());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklists'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error?.message ?? 'Error loading checklists'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchChecklists(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.checklists.isEmpty) {
            return const Center(child: Text('No checklists yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.checklists.length,
            itemBuilder: (context, index) {
              final checklist = provider.checklists[index];
              return _ChecklistCard(checklist: checklist);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create checklist screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final Checklist checklist;

  const _ChecklistCard({required this.checklist});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(checklist.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(checklist.description),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: checklist.items.isEmpty
                  ? 0
                  : checklist.items.where((i) => i.isCompleted).length /
                        checklist.items.length,
            ),
            const SizedBox(height: 4),
            Text(
              '${checklist.items.where((i) => i.isCompleted).length}/${checklist.items.length} items completed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () {
          // Navigate to checklist detail
        },
      ),
    );
  }
}
