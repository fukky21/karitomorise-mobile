import 'package:flutter/material.dart';

class SearchResultScreenState {
  const SearchResultScreenState({
    @required this.eventIds,
    @required this.isFetchabled,
  });

  final List<String> eventIds;
  final bool isFetchabled;
}
