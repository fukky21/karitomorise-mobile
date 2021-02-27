import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

import '../../blocs/like_event_button_bloc/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import 'custom_snack_bar.dart';

class LikeEventButton extends StatelessWidget {
  const LikeEventButton({
    @required this.eventId,
    @required this.isSignedIn,
    this.size = 30,
  });

  final String eventId;
  final bool isSignedIn;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LikeEventButtonBloc>(
      create: (context) => LikeEventButtonBloc(context: context),
      child: BlocBuilder<LikeEventButtonBloc, LikeEventButtonState>(
        builder: (context, _) {
          return Consumer<LikesProvider>(
            builder: (context, provider, _) {
              final _likes = provider?.likes ?? [];
              final _isLiked = _likes.contains(eventId);
              return LikeButton(
                isLiked: _isLiked,
                size: size,
                likeBuilder: (_) {
                  return Icon(
                    FontAwesomeIcons.solidHeart,
                    color: _isLiked ? AppColors.favorite : AppColors.grey60,
                    size: size,
                  );
                },
                onTap: (_) async {
                  if (isSignedIn) {
                    if (_isLiked) {
                      context
                          .read<LikeEventButtonBloc>()
                          .add(UnLikeEventOnPressed(eventId: eventId));
                      return false;
                    } else {
                      context
                          .read<LikeEventButtonBloc>()
                          .add(LikeEventOnPressed(eventId: eventId));
                      return true;
                    }
                  } else {
                    showSnackBar(context, 'サインインしてください');
                  }
                  return false;
                },
              );
            },
          );
        },
      ),
    );
  }
}
