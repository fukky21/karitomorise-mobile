import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../util/index.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    @required this.iconType,
    this.size = 55,
    @required this.onTap,
  });

  final int iconType;
  final double size;
  final void Function() onTap;

  // iconType
  static const iconTypeFacebook = 1;
  static const iconTypeGoogle = 2;
  static const iconTypeTwitter = 3;

  @override
  Widget build(BuildContext context) {
    if (iconType == iconTypeFacebook) {
      return Material(
        color: AppColors.facebook,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          child: SizedBox(
            width: size,
            height: size,
            child: const Icon(
              FontAwesomeIcons.facebookF,
              color: AppColors.white,
            ),
          ),
          onTap: onTap,
        ),
      );
    }
    if (iconType == iconTypeGoogle) {
      return RawMaterialButton(
        fillColor: AppColors.white,
        shape: const CircleBorder(),
        elevation: 0,
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: size, maxHeight: size),
        child: Image.asset(AppIcons.google),
        onPressed: onTap,
      );
    }
    if (iconType == iconTypeTwitter) {
      return Material(
        color: AppColors.twitter,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          child: SizedBox(
            width: size,
            height: size,
            child: const Icon(
              FontAwesomeIcons.twitter,
              color: AppColors.white,
            ),
          ),
          onTap: onTap,
        ),
      );
    }
    return Container();
  }
}
