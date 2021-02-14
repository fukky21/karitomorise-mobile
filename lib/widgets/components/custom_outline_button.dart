import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
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
      child: OutlineButton(
        child: AutoSizeText(
          labelText ?? '',
          style: TextStyle(
            color: isDanger
                ? Theme.of(context).errorColor
                : Theme.of(context).primaryColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          maxLines: maxLines,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        borderSide: BorderSide(
          width: 1,
          color: isDanger
              ? Theme.of(context).errorColor
              : Theme.of(context).primaryColor,
        ),
        highlightColor: isDanger
            ? Theme.of(context).errorColor
            : Theme.of(context).primaryColor,
        highlightedBorderColor: isDanger
            ? Theme.of(context).errorColor
            : Theme.of(context).primaryColor,
        onPressed: onPressed,
      ),
    );
  }
}
