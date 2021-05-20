import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({
    @required this.filePath,
    @required this.radius,
    this.onTap,
  });

  final String filePath;
  final double radius;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CircularProfileAvatar(
      '',
      borderColor: Theme.of(context).primaryColor,
      borderWidth: 2,
      radius: radius,
      onTap: onTap,
      child: filePath != null ? Image.asset(filePath) : null,
    );
  }
}
