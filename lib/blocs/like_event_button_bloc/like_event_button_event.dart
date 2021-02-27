import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LikeEventButtonEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class LikeEventOnPressed extends LikeEventButtonEvent {
  LikeEventOnPressed({@required this.eventId});

  final String eventId;
}

class UnLikeEventOnPressed extends LikeEventButtonEvent {
  UnLikeEventOnPressed({@required this.eventId});

  final String eventId;
}
