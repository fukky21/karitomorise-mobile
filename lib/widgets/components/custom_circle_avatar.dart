import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({@required this.filePath, @required this.radius});

  final String filePath;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircularProfileAvatar(
      '',
      child: Image.asset(filePath),
      borderColor: Theme.of(context).primaryColor,
      borderWidth: 2,
      radius: radius,
    );
  }
}
