import 'package:flutter/material.dart';

class AppEvent {
  AppEvent({
    this.id,
    this.uid,
    this.description,
    this.type,
    this.questRank,
    this.targetLevel,
    this.playTime,
    this.commentCount,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String uid;
  String description;
  EventType type;
  EventQuestRank questRank;
  EventTargetLevel targetLevel;
  EventPlayTime playTime;
  int commentCount;
  DateTime createdAt;
  DateTime updatedAt;
}

enum EventType { story, quest, rta, other }

extension EventTypeExtension on EventType {
  static final _ids = {
    EventType.story: 1,
    EventType.quest: 2,
    EventType.rta: 3,
    EventType.other: 4,
  };
  int get id => _ids[this];

  static final _names = {
    EventType.story: 'ストーリー攻略',
    EventType.quest: 'クエスト周回',
    EventType.rta: 'RTA',
    EventType.other: 'その他',
  };
  String get name => _names[this];
}

EventType getEventType({@required int id}) {
  for (final type in EventType.values) {
    if (type.id == id) {
      return type;
    }
  }
  return null;
}

enum EventQuestRank { low, high }

extension EventQuestRankExtension on EventQuestRank {
  static final _ids = {
    EventQuestRank.low: 1,
    EventQuestRank.high: 2,
  };
  int get id => _ids[this];

  static final _names = {
    EventQuestRank.low: '下位',
    EventQuestRank.high: '上位',
  };
  String get name => _names[this];
}

EventQuestRank getEventQuestRank({@required int id}) {
  for (final questRank in EventQuestRank.values) {
    if (questRank.id == id) {
      return questRank;
    }
  }
  return null;
}

enum EventTargetLevel { all, beginner, intermediate, advanced }

extension EventTargetLevelExtension on EventTargetLevel {
  static final _ids = {
    EventTargetLevel.all: 1,
    EventTargetLevel.beginner: 2,
    EventTargetLevel.intermediate: 3,
    EventTargetLevel.advanced: 4,
  };
  int get id => _ids[this];

  static final _names = {
    EventTargetLevel.all: '誰でも歓迎',
    EventTargetLevel.beginner: '初心者歓迎',
    EventTargetLevel.intermediate: '中級者歓迎',
    EventTargetLevel.advanced: '上級者歓迎',
  };
  String get name => _names[this];
}

EventTargetLevel getEventTargetLevel({@required int id}) {
  for (final targetLevel in EventTargetLevel.values) {
    if (targetLevel.id == id) {
      return targetLevel;
    }
  }
  return null;
}

enum EventPlayTime {
  less1H,
  for1to2H,
  for2to3H,
  for3to4H,
  for4to5H,
  for5to6H,
  over6H,
}

extension EventPlayTimeExtension on EventPlayTime {
  static final _ids = {
    EventPlayTime.less1H: 1,
    EventPlayTime.for1to2H: 2,
    EventPlayTime.for2to3H: 3,
    EventPlayTime.for3to4H: 4,
    EventPlayTime.for4to5H: 5,
    EventPlayTime.for5to6H: 6,
    EventPlayTime.over6H: 7,
  };
  int get id => _ids[this];

  static final _names = {
    EventPlayTime.less1H: '1時間未満',
    EventPlayTime.for1to2H: '1~2時間',
    EventPlayTime.for2to3H: '2~3時間',
    EventPlayTime.for3to4H: '3~4時間',
    EventPlayTime.for4to5H: '4~5時間',
    EventPlayTime.for5to6H: '5~6時間',
    EventPlayTime.over6H: '6時間以上',
  };
  String get name => _names[this];
}

EventPlayTime getEventPlayTime({@required int id}) {
  for (final playTime in EventPlayTime.values) {
    if (playTime.id == id) {
      return playTime;
    }
  }
  return null;
}
