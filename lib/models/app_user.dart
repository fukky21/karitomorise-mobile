class AppUser {
  AppUser({
    this.id,
    this.displayName,
    this.biography,
    this.avatarType,
    this.mainWeaponType,
    this.firstPlayedSeries,
    this.createdAt,
    this.updatedAt,
  });

  String id;
  String displayName;
  String biography;
  int avatarType;
  int mainWeaponType;
  int firstPlayedSeries;
  DateTime createdAt;
  DateTime updatedAt;
}
