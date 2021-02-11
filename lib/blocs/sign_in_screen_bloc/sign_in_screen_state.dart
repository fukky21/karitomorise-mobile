import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SignInScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignInInProgress extends SignInScreenState {}

class SignInSuccess extends SignInScreenState {}

class SignInFailure extends SignInScreenState {
  SignInFailure({@required this.errorType});

  final int errorType;

  // errorType
  static const errorTypeInvalidEmail = 1;
  static const errorTypeUserNotFound = 2;
  static const errorTypeWrongPassword = 3;
  static const errorTypeOther = 4;
}
