import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SignUpScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignUpInProgress extends SignUpScreenState {}

class SignUpSuccess extends SignUpScreenState {
  SignUpSuccess({@required this.email});

  final String email;
}

class SignUpFailure extends SignUpScreenState {
  SignUpFailure({@required this.errorType});

  final int errorType;

  // errorType
  static const errorTypeEmailAlreadyInUse = 1;
  static const errorTypeInvalidEmail = 2;
  static const errorTypeWeakPassword = 3;
  static const errorTypeOther = 4;
}
