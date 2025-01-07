// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initialize() async {
//     const initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await _notifications.initialize(initializationSettings);
//   }

//   Future<void> showNotification(String title, String body) async {
//     const androidDetails = AndroidNotificationDetails(
//       'traceroute_channel',
//       'Traceroute Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//     const details = NotificationDetails(
//       android: androidDetails,
//     );

//     await _notifications.show(0, title, body, details);
//   }
// }
