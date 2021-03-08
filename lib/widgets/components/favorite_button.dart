import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

import '../../blocs/favorite_button_bloc/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import 'custom_snack_bar.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    @required this.eventId,
    @required this.isSignedIn,
    this.size = 30,
  });

  final String eventId;
  final bool isSignedIn;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FavoriteButtonBloc>(
      create: (context) => FavoriteButtonBloc(context: context),
      child: BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
        builder: (context, _) {
          return Consumer<FavoritesProvider>(
            builder: (context, provider, _) {
              final _favorites = provider?.favorites ?? [];
              final _isFavorited = _favorites.contains(eventId);
              return LikeButton(
                isLiked: _isFavorited,
                size: size,
                likeBuilder: (isLiked) {
                  return Icon(
                    FontAwesomeIcons.solidHeart,
                    color: isLiked ? AppColors.favorite : AppColors.grey60,
                    size: size,
                  );
                },
                onTap: (isLiked) async {
                  if (isSignedIn) {
                    if (isLiked) {
                      context
                          .read<FavoriteButtonBloc>()
                          .add(RemoveFromFavoritesOnPressed(eventId: eventId));
                      return !isLiked;
                    } else {
                      context
                          .read<FavoriteButtonBloc>()
                          .add(AddToFavoritesOnPressed(eventId: eventId));
                      return !isLiked;
                    }
                  }
                  showSnackBar(context, 'サインインするとお気に入り登録できます');
                  return isLiked;
                },
              );
            },
          );
        },
      ),
    );
  }
}
