import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

class NotificationService {
  static final Client client = Client();

  static const String serverKey =
    "AAAAmi9ZGYY:APA91bGQutZqAX4fYexnXjoKXJ85znM9LivPkdP2FlmMNLU_6lOFSMT4fo2sauVEOgDnssGov8dc-oWU6keeNfyaSDYb0IBUzWorxxsM7T0l0VTbFF6y1OKjykYxR1C3IyDXgWi18v7E";
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
