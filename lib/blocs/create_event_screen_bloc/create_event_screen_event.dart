import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

abstract class CreateEventScreenEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class CreateEventOnPressed extends CreateEventScreenEvent {
  CreateEventOnPressed({@required this.event});

  final AppEvent event;
}
