import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

abstract class EditUserScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class Initialized extends EditUserScreenEvent {}

class UpdateUserOnPressed extends EditUserScreenEvent {
  UpdateUserOnPressed({@required this.user});

  final AppUser user;
}
