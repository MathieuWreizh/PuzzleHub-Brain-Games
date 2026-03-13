import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerWidget extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onTimeUp;
  final bool running;

  const TimerWidget({
    super.key,
    required this.durationSeconds,
    required this.onTimeUp,
    this.running = true,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    if (widget.running) _startTimer();
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.running != widget.running) {
      widget.running ? _startTimer() : _stopTimer();
    }
  }

  void _startTimer() {
    _remaining = widget.durationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _stopTimer();
        widget.onTimeUp();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remaining / widget.durationSeconds;
    final color = progress > 0.5
        ? AppTheme.correct
        : progress > 0.25
            ? Colors.orange
            : AppTheme.wrong;

    return Row(
      children: [
        Icon(Icons.timer_outlined, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$_remaining s',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
