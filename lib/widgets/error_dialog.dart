import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final String dismissButtonText;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onDismiss,
    this.dismissButtonText = 'OK',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: Text(dismissButtonText),
        ),
      ],
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final String dismissButtonText;

  const SuccessDialog({
    super.key,
    this.title = 'Success',
    required this.message,
    this.onDismiss,
    this.dismissButtonText = 'OK',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: Text(dismissButtonText),
        ),
      ],
    );
  }
}

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
