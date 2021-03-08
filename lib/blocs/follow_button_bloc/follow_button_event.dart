import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class FollowButtonEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class FollowUserOnPressed extends FollowButtonEvent {
  FollowUserOnPressed({@required this.uid});

  final String uid;
}

class UnFollowUserOnPressed extends FollowButtonEvent {
  UnFollowUserOnPressed({@required this.uid});

  final String uid;
}
