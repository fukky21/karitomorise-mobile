import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';

import '../../utils/index.dart';
import '../../widgets/screens/index.dart';

class CommentButton extends StatelessWidget {
  const CommentButton({
    @required this.eventId,
    this.size = 20,
    this.commentCount,
  });

  final String eventId;
  final double size;
  final int commentCount;

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      isLiked: false,
      likeCount: commentCount,
      size: size,
      likeBuilder: (_) {
        return Icon(
          FontAwesomeIcons.comment,
          color: AppColors.grey60,
          size: size,
        );
      },
      countBuilder: (count, _, __) {
        if (count != null && count != 0) {
          return Container(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: AppColors.grey60,
                fontSize: size * 0.7,
              ),
            ),
          );
        }
        return Container();
      },
      onTap: (_) async {
        if (eventId != null) {
          await Navigator.pushNamed(
            context,
            ShowEventCommentsScreen.route,
            arguments: ShowEventCommentsScreenArguments(eventId: eventId),
          );
        }
        return false;
      },
    );
  }
}
