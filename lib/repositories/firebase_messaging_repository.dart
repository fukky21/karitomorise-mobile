import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingRepository {
  final firebaseMessaging = FirebaseMessaging.instance;

  Future<String> getToken() async {
    final token = await firebaseMessaging.getToken();
    return token;
  }

  Stream<String> getTokenRefreshStream() {
    return firebaseMessaging.onTokenRefresh;
  }

  Future<void> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    await firebaseMessaging.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );
  }

  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }
}
