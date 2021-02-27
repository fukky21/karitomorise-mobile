import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SignInScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignInOnPressed extends SignInScreenEvent {
  SignInOnPressed({@required this.email, @required this.password});

  final String email;
  final String password;
}
