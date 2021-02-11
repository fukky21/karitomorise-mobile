import 'package:flutter/material.dart';

import '../../util/index.dart';

class CustomRaisedButton extends StatelessWidget {
  const CustomRaisedButton({
    this.width = double.infinity,
    this.height = 50,
    @required this.labelText,
    this.fontSize,
    this.maxLines = 1,
    this.isDanger = false,
    @required this.onPressed,
  });

  final double width;
  final double height;
  final String labelText;
  final double fontSize;
  final int maxLines;
  final bool isDanger;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: RaisedButton(
        child: Text(
          labelText ?? '',
          style: TextStyle(
            color: AppColors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          maxLines: maxLines,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        color: isDanger
            ? Theme.of(context).errorColor
            : Theme.of(context).primaryColor,
        elevation: 0,
        highlightElevation: 0,
        onPressed: onPressed,
      ),
    );
  }
}
