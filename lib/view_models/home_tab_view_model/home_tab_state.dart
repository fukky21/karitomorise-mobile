import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

abstract class HomeTabState extends Equatable {
  @override
  List<Object> get props => const [];
}

class HomeTabLoading extends HomeTabState {}

class HomeTabLoadSuccess extends HomeTabState {
  HomeTabLoadSuccess({@required this.posts});

  final List<Post> posts;
}

class HomeTabLoadFailure extends HomeTabState {}
