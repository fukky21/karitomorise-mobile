import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceRepository {
  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistory = prefs.getStringList('searchHistory') ?? [];

    return List.from(searchHistory.reversed);
  }

  Future<void> addToSearchHistory({@required String keyword}) async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistory = prefs.getStringList('searchHistory') ?? []
      ..removeWhere((history) => history == keyword)
      ..add(keyword);

    await prefs.setStringList('searchHistory', searchHistory);
  }

  Future<void> removeFromSearchHistory({@required String keyword}) async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistory = prefs.getStringList('searchHistory') ?? []
      ..removeWhere((history) => history == keyword);

    await prefs.setStringList('searchHistory', searchHistory);
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', []);
  }

  Future<bool> hasAgreedToTermsOfService() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAgreedToTermsOfService =
        prefs.getBool('hasAgreedToTermsOfService') ?? false;
    return hasAgreedToTermsOfService;
  }

  Future<void> agreeToTermsOfService() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAgreedToTermsOfService', true);
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
