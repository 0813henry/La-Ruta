import 'package:flutter/material.dart';
import 'dart:async';

// Este archivo contiene un widget que muestra el tiempo transcurrido desde que un pedido fue enviado a la cocina.

class TiempoWidget extends StatefulWidget {
  final DateTime fechaEnvio;

  const TiempoWidget({required this.fechaEnvio, Key? key}) : super(key: key);

  @override
  _TiempoWidgetState createState() => _TiempoWidgetState();
}

class _TiempoWidgetState extends State<TiempoWidget> {
  late Timer _timer;
  late Duration _tiempoTranscurrido;

  @override
  void initState() {
    super.initState();
    _tiempoTranscurrido = DateTime.now().difference(widget.fechaEnvio);
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      setState(() {
        _tiempoTranscurrido = DateTime.now().difference(widget.fechaEnvio);
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
    final String tiempo = '${_tiempoTranscurrido.inMinutes} min';

    return Row(
      children: [
        Icon(Icons.timer, color: Colors.grey),
        SizedBox(width: 5),
        Text(tiempo, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
