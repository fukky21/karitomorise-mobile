import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: BigTip(
          title: Text('エラーが発生しました'),
          child: Icon(Icons.error_outline_sharp),
        ),
      ),
    );
  }
}
