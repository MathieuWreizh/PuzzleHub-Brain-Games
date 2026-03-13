import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const int _dailyChallengeId = 1;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (!_initialized) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleDailyChallenge({required bool isFr}) async {
    if (!_initialized) return;
    await _plugin.periodicallyShowWithDuration(
      _dailyChallengeId,
      isFr ? 'Défis du jour disponibles ! ☀️' : 'Daily challenges available! ☀️',
      isFr
          ? 'Relevez vos défis pour gagner des crédits.'
          : 'Complete your daily challenges to earn credits.',
      const Duration(hours: 24),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_challenges',
          isFr ? 'Défis quotidiens' : 'Daily challenges',
          channelDescription: isFr
              ? 'Rappel pour les défis quotidiens'
              : 'Daily challenge reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelDailyChallenge() async {
    if (!_initialized) return;
    await _plugin.cancel(_dailyChallengeId);
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }
}
