import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SignUpScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignUpOnPressed extends SignUpScreenEvent {
  SignUpOnPressed({
    @required this.email,
    @required this.password,
    @required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;
}
