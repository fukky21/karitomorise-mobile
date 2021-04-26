import 'package:equatable/equatable.dart';

abstract class SearchTabEvent extends Equatable {
  @override
  List<Object> get props => const [];
}

class Initialized extends SearchTabEvent {}
