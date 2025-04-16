import 'package:flutter/material.dart';
import 'dart:async';

class TimerProgressWidget extends StatefulWidget {
  final DateTime startTime;

  TimerProgressWidget({required this.startTime});

  @override
  _TimerProgressWidgetState createState() => _TimerProgressWidgetState();
}

class _TimerProgressWidgetState extends State<TimerProgressWidget> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('${_elapsed.inMinutes}:${_elapsed.inSeconds % 60} min');
  }
}
