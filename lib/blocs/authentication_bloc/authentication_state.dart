import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => const [];
}

class AuthenticationInProgress extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  AuthenticationSuccess({@required this.currentUser});

  final CurrentUser currentUser;
}

class AuthenticationFailure extends AuthenticationState {}
