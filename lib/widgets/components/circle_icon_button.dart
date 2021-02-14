import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/index.dart';

enum CircleIconButtonType { facebook, google, twitter }

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    @required this.type,
    this.size = 55,
    @required this.onTap,
  });

  final CircleIconButtonType type;
  final double size;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CircleIconButtonType.facebook:
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
      case CircleIconButtonType.google:
        return RawMaterialButton(
          fillColor: AppColors.white,
          shape: const CircleBorder(),
          elevation: 0,
          padding: const EdgeInsets.all(10),
          constraints: BoxConstraints(maxWidth: size, maxHeight: size),
          child: Image.asset('assets/icons/google_icon.png'),
          onPressed: onTap,
        );
      case CircleIconButtonType.twitter:
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
