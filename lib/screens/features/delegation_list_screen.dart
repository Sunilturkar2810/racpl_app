import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/delegation_provider.dart';
import '../../models/delegation_model.dart';

class DelegationListScreen extends StatefulWidget {
  const DelegationListScreen({super.key});

  @override
  State<DelegationListScreen> createState() => _DelegationListScreenState();
}

class _DelegationListScreenState extends State<DelegationListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<DelegationProvider>().fetchDelegations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delegations'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<DelegationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error?.message ?? 'Error loading delegations'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchDelegations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.delegations.isEmpty) {
            return const Center(child: Text('No delegations yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.delegations.length,
            itemBuilder: (context, index) {
              final delegation = provider.delegations[index];
              return _DelegationCard(delegation: delegation);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create delegation screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DelegationCard extends StatelessWidget {
  final Delegation delegation;

  const _DelegationCard({required this.delegation});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in-progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(delegation.taskName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(delegation.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(delegation.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    delegation.status,
                    style: TextStyle(
                      color: _getStatusColor(delegation.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to delegation detail
        },
      ),
    );
  }
}
