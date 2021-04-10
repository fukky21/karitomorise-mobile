import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

abstract class SearchResultScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SearchInProgress extends SearchResultScreenState {}

class SearchSuccess extends SearchResultScreenState {
  SearchSuccess({@required this.events});

  final List<AppEvent> events;
}

class SearchFailure extends SearchResultScreenState {}
