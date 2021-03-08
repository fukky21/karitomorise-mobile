import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ShowEventCommentsScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class Initialized extends ShowEventCommentsScreenEvent {
  Initialized({@required this.eventId});

  final String eventId;
}

class Listened extends ShowEventCommentsScreenEvent {}

class CreateCommentOnPressed extends ShowEventCommentsScreenEvent {
  CreateCommentOnPressed({@required this.message});

  final String message;
}
