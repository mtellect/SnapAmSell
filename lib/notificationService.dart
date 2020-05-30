import 'dart:convert';

import 'package:http/http.dart';

class NotificationService {
  static final Client client = Client();

  static const String serverKey =
      "AAAAcRxyR0U:APA91bGFclir9ZA2djETfX2jFEcgFPCSbIcasQ5I-hdoQvnpPS0SVq0QUPBLT4okNQf2JB6ozEWIXC7pmUsLvzoxBRE_B6W3M5t7R3s3lv9hhQ-cYXRdLQWkA_n7Fouu97_nqBMV5PG4";

  static sendPush({
    String topic,
    String token,
    int liveTimeInSeconds = (Duration.secondsPerDay * 7),
    String title,
    String body,
    String image,
    Map data,
    String tag,
  }) async {
    String fcmToken = topic != null ? '/topics/$topic' : token;
    data = data ?? Map();
    data['click_action'] = 'FLUTTER_NOTIFICATION_CLICK';
    data['id'] = '1';
    data['status'] = 'done';
    client.post(
      'https://fcm.googleapis.com/fcm/send',
      body: json.encode({
        'notification': {
          'body': body,
          'title': title,
          'image': image,
          'icon': "ic_notify",
          'color': "#ffffff",
          'tag': tag
        },
        'data': data,
        'to': fcmToken,
        'time_to_live': liveTimeInSeconds
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
    );
  }
}
