import 'package:flutter/material.dart';

class VentasChart extends StatelessWidget {
  const VentasChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.blue,
      child: const Center(child: Text('Gráfico de Ventas')),
    );
  }
}
