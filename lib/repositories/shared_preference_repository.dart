import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceRepository {
  Future<List<String>> getSearchHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistories = prefs.getStringList('searchHistories') ?? [];

    return List.from(searchHistories.reversed);
  }

  Future<void> addSearchKeyword({@required String keyword}) async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistories = prefs.getStringList('searchHistories') ?? []
      ..removeWhere((history) => history == keyword)
      ..add(keyword);

    await prefs.setStringList('searchHistories', searchHistories);
  }

  Future<void> deleteSearchKeyword({@required String keyword}) async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistories = prefs.getStringList('searchHistories') ?? []
      ..removeWhere((history) => history == keyword);

    await prefs.setStringList('searchHistories', searchHistories);
  }
}
