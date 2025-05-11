import 'package:flutter/material.dart';
import 'dart:async';

class TimerProgressWidget extends StatefulWidget {
  final DateTime startTime;
  final Duration maxDuration;

  const TimerProgressWidget({
    required this.startTime,
    required this.maxDuration,
    super.key,
  });

  @override
  _TimerProgressWidgetState createState() => _TimerProgressWidgetState();
}

class _TimerProgressWidgetState extends State<TimerProgressWidget> {
  late Timer _timer;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = _calculateProgress();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _progress = _calculateProgress();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  double _calculateProgress() {
    final elapsed = DateTime.now().difference(widget.startTime);
    return (elapsed.inSeconds / widget.maxDuration.inSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: _progress,
      backgroundColor: Colors.grey[300],
      color: _progress < 0.5
          ? Colors.green
          : (_progress < 0.8 ? Colors.orange : Colors.red),
    );
  }
}
