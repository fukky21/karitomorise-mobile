import 'package:flutter/material.dart';

class SearchTabState {
  SearchTabState({@required this.eventIds, @required this.isFetchabled});

  final List<String> eventIds;
  final bool isFetchabled;
}
