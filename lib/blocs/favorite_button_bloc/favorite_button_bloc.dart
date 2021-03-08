import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/index.dart';
import '../../repositories/index.dart';
import '../../widgets/components/index.dart';
import 'favorite_button_event.dart';
import 'favorite_button_state.dart';

class FavoriteButtonBloc
    extends Bloc<FavoriteButtonEvent, FavoriteButtonState> {
  FavoriteButtonBloc({@required this.context}) : super(null) {
    _userRepository = context.read<FirebaseUserRepository>();
    _favoritesProvider = context.read<FavoritesProvider>();
  }

  final BuildContext context;
  FirebaseUserRepository _userRepository;
  FavoritesProvider _favoritesProvider;

  @override
  Stream<FavoriteButtonState> mapEventToState(
    FavoriteButtonEvent event,
  ) async* {
    if (event is AddToFavoritesOnPressed) {
      yield* _mapAddToFavoritesOnPressedToState(event.eventId);
    }
    if (event is RemoveFromFavoritesOnPressed) {
      yield* _mapRemoveFromFavoritesOnPressedToState(event.eventId);
    }
  }

  Stream<FavoriteButtonState> _mapAddToFavoritesOnPressedToState(
    String eventId,
  ) async* {
    try {
      await _userRepository.addToFavorites(eventId);
      await _favoritesProvider.reload();
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
    }
  }

  Stream<FavoriteButtonState> _mapRemoveFromFavoritesOnPressedToState(
    String eventId,
  ) async* {
    try {
      await _userRepository.removeFromFavorites(eventId);
      await _favoritesProvider.reload();
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
    }
  }
}
