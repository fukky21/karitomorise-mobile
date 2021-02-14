import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

abstract class FollowUserButtonEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class FollowUserOnPressed extends FollowUserButtonEvent {
  FollowUserOnPressed({@required this.user});

  final AppUser user;
}

class UnFollowUserOnPressed extends FollowUserButtonEvent {
  UnFollowUserOnPressed({@required this.user});

  final AppUser user;
}
