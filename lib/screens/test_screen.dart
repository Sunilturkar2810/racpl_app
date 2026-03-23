import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dio_service.dart';
import '../utils/constants.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _responseText = 'Press button to test API';
  bool _isLoading = false;

  Future<void> _testApiCall() async {
    setState(() {
      _isLoading = true;
      _responseText = 'Loading...';
    });

    try {
      final dioService = context.read<DioService>();

      // Make a test API call using the raw dio client to test logging
      final _ = await dioService.dio.get('/users');

      setState(() {
        _responseText =
            'API Call made successfully. Check console logs for details.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _responseText =
            'API Call attempted. Check console logs for response details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Logging Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RACPL API Base URL:\n${AppConstants.apiBaseUrl}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _testApiCall,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test API Call'),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _responseText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Check console for detailed API logs 📡',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
