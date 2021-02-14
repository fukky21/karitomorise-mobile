import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SignInScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignInWithEmailAndPasswordOnPressed extends SignInScreenEvent {
  SignInWithEmailAndPasswordOnPressed({
    @required this.email,
    @required this.password,
  });

  final String email;
  final String password;
}

class SignInWithFacebookOnPressed extends SignInScreenEvent {}

class SignInWithGoogleOnPressed extends SignInScreenEvent {}

class SignInWithTwitterOnPressed extends SignInScreenEvent {}
