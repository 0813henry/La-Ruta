import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 10),
            Text(
              message!,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    );
  }
}
