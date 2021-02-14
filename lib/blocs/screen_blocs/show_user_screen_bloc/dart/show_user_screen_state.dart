import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../models/index.dart';

abstract class ShowUserScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class Loading extends ShowUserScreenState {}

class LoadSuccess extends ShowUserScreenState {
  LoadSuccess({@required this.editable, @required this.user});

  final bool editable;
  final AppUser user;
}

class LoadFailure extends ShowUserScreenState {
  LoadFailure({@required this.errorType});

  final int errorType;

  // errorType
  static const errorTypeUserAlreadyDeleted = 1;
  static const errorTypeOther = 2;
}
