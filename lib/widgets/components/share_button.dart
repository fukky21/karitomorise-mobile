import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';

import '../../utils/index.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    @required this.eventId,
    this.size = 20,
  });

  final String eventId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      isLiked: false,
      size: size,
      likeBuilder: (_) {
        return Icon(
          FontAwesomeIcons.shareAlt,
          color: AppColors.grey60,
          size: size,
        );
      },
      onTap: (_) async {
        // TODO(Fukky21): シェア機能を実装する
        return false;
      },
    );
  }
}
