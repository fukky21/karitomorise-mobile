import 'package:equatable/equatable.dart';

abstract class SignButtonEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class SignOutOnPressed extends SignButtonEvent {}
