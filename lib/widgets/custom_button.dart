import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.enabled && !widget.isLoading
            ? widget.onPressed
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Text(widget.label),
      ),
    );
  }
}
