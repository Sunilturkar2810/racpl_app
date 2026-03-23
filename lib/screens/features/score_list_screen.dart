import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/score_provider.dart';
import '../../models/score_model.dart';

class ScoreListScreen extends StatefulWidget {
  const ScoreListScreen({super.key});

  @override
  State<ScoreListScreen> createState() => _ScoreListScreenState();
}

class _ScoreListScreenState extends State<ScoreListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ScoreProvider>().fetchScores());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Scores'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ScoreProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error?.message ?? 'Error loading scores'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchScores(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.scores.isEmpty) {
            return const Center(child: Text('No scores yet'));
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Average Score',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.averageScore.toStringAsFixed(1)}/100',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: provider.averageScore / 100,
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.scores.length,
                  itemBuilder: (context, index) {
                    final score = provider.scores[index];
                    return _ScoreCard(score: score);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final Score score;

  const _ScoreCard({required this.score});

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getScoreColor(score.score),
          child: Text(
            score.score.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(score.metric),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('${score.month} ${score.year}'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: score.score / 100,
              color: _getScoreColor(score.score),
            ),
          ],
        ),
        onTap: () {
          // Navigate to score detail
        },
      ),
    );
  }
}
