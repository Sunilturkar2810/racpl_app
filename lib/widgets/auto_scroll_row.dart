import 'dart:async';
import 'package:flutter/material.dart';

/// Auto-scrolling horizontal row — smoothly scrolls left, then right, loops.
/// Pauses when user touches it, resumes after 2 seconds.
class AutoScrollRow extends StatefulWidget {
  final List<Widget> children;

  const AutoScrollRow({super.key, required this.children});

  @override
  State<AutoScrollRow> createState() => _AutoScrollRowState();
}

class _AutoScrollRowState extends State<AutoScrollRow> {
  late final ScrollController _controller;
  Timer? _scrollTimer;
  Timer? _resumeTimer;
  bool _forward = true;
  bool _paused = false;

  static const double _speed = 0.5; // pixels per tick
  static const Duration _tickInterval = Duration(milliseconds: 16); // ~60fps
  static const Duration _resumeDelay = Duration(seconds: 2);
  static const Duration _startDelay = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    // Start auto-scroll after a short delay so layout is ready
    Future.delayed(_startDelay, _startScrolling);
  }

  void _startScrolling() {
    if (!mounted) return;
    _scrollTimer = Timer.periodic(_tickInterval, (_) {
      if (_paused || !_controller.hasClients) return;

      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return; // content fits — no need to scroll

      final current = _controller.offset;

      if (_forward) {
        if (current >= max) {
          _forward = false;
        } else {
          _controller.jumpTo((current + _speed).clamp(0, max));
        }
      } else {
        if (current <= 0) {
          _forward = true;
        } else {
          _controller.jumpTo((current - _speed).clamp(0, max));
        }
      }
    });
  }

  void _onPointerDown(PointerDownEvent _) {
    _paused = true;
    _resumeTimer?.cancel();
  }

  void _onPointerUp(PointerEvent _) {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(_resumeDelay, () {
      if (mounted) _paused = false;
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _resumeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: widget.children),
      ),
    );
  }
}
