import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class FavoriteButtonEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class AddToFavoritesOnPressed extends FavoriteButtonEvent {
  AddToFavoritesOnPressed({@required this.eventId});

  final String eventId;
}

class RemoveFromFavoritesOnPressed extends FavoriteButtonEvent {
  RemoveFromFavoritesOnPressed({@required this.eventId});

  final String eventId;
}
