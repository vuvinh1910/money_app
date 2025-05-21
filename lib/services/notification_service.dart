import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
  InitializationSettings(android: androidSettings);

  // Khởi tạo plugin với callback xử lý khi nhấn thông báo
  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Xử lý khi nhấn vào thông báo
      // Bạn có thể thêm logic để mở một màn hình cụ thể hoặc thực hiện hành động
      print('Thông báo được nhấn: ${response.payload}');
    },
  );
}

Future<void> showTestNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'test_channel_id', // ID
    'Test Channel', // Name
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Thông báo thử nghiệm',
    'Đây là nội dung thông báo.',
    notificationDetails,
    payload: 'data', // Payload để truyền dữ liệu khi nhấn thông báo
  );
}