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

  Future<void> deleteAllSearchHistories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistories', []);
  }

  Future<bool> checkIsFirstLaunchFinished() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunchFinished =
        prefs.getBool('isFirstLaunchFinished') ?? false;
    if (!isFirstLaunchFinished) {
      await prefs.setBool('isFirstLaunchFinished', true);
    }
    return isFirstLaunchFinished;
  }

  Future<List<String>> getBlockList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('blockList') ?? [];
  }

  Future<void> addToBlockList({@required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'blockList',
      prefs.getStringList('blockList') ?? []
        ..removeWhere((blockedUid) => blockedUid == uid)
        ..add(uid),
    );
  }

  Future<void> clearBlockList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blockList', []);
  }
}
