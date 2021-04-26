import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SearchTabState extends Equatable {
  @override
  List<Object> get props => const [];
}

class InitializeInProgress extends SearchTabState {}

class InitializeSuccess extends SearchTabState {
  InitializeSuccess({@required this.hotwords});

  final List<String> hotwords;
}

class InitializeFailure extends SearchTabState {}
