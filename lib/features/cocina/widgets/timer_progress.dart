import 'package:flutter/material.dart';
import 'dart:async';

class TimerProgress extends StatefulWidget {
  final DateTime startTime;
  final Duration maxDuration;

  const TimerProgress({
    required this.startTime,
    required this.maxDuration,
    Key? key,
  }) : super(key: key);

  @override
  _TimerProgressState createState() => _TimerProgressState();
}

class _TimerProgressState extends State<TimerProgress> {
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
    if (_timer.isActive) {
      _timer.cancel(); // Asegurarse de cancelar el Timer
    }
    super.dispose();
  }

  double _calculateProgress() {
    final elapsed = DateTime.now().difference(widget.startTime);
    final totalSeconds = widget.maxDuration.inSeconds;
    if (totalSeconds == 0) return 1.0; // Evitar división por cero
    return (elapsed.inSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[300],
          color: _progress < 0.5
              ? Colors.green
              : (_progress < 0.8 ? Colors.orange : Colors.red),
        );
      },
    );
  }
}
