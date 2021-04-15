class AppEvent {
  AppEvent({
    this.id,
    this.uid,
    this.description,
    this.commentCount,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String uid;
  String description;
  int commentCount;
  DateTime createdAt;
  DateTime updatedAt;
}
