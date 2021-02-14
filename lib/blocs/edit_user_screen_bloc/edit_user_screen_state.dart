import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

abstract class EditUserScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class InitializeInProgress extends EditUserScreenState {}

class InitializeSuccess extends EditUserScreenState {
  InitializeSuccess({@required this.user});

  final AppUser user;
}

class InitializeFailure extends EditUserScreenState {}

class UpdateUserInProgress extends EditUserScreenState {}

class UpdateUserSuccess extends EditUserScreenState {}

class UpdateUserFailure extends EditUserScreenState {}
