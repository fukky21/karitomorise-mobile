import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SearchResultScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class Initialized extends SearchResultScreenEvent {
  Initialized({@required this.keyword});

  final String keyword;
}
