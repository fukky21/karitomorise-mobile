import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SignInScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignInInProgress extends SignInScreenState {}

class SignInSuccess extends SignInScreenState {
  SignInSuccess({@required this.uid});

  final String uid;
}

class SignInFailure extends SignInScreenState {
  SignInFailure({@required this.type});

  final SignInFailureType type;
}

enum SignInFailureType { invalidEmail, userNotFound, wrongPassword, other }
