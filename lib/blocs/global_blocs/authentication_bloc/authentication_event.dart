import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class AppStarted extends AuthenticationEvent {}

class SignedIn extends AuthenticationEvent {}

class SignedOut extends AuthenticationEvent {}
