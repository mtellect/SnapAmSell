import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailService {
  static String apiBase = "https://api.sendgrid.com/v3/mail/send";
  static String secret =
      "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";
  //static String secret = appSettingsModel.getString(SEND_GRID_KEY);
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${EmailService.secret}',
    'Content-Type': 'application/json'
  };

  static init() {}

  static send({String to}) async {
    Map body = {
      "from": {"email": "Info@strock.fun"},
      "personalizations": [
        {
          "to": [
            {"email": "ammaugost@gmail.com"}
          ],
          "dynamic_template_data": {
            "subject": "Maugost is testing how this works",
            "name": "Maugost AppTest"
          }
        }
      ],
      "template_id": 'd-742db57c6c5149cea38fccc89a5a1a38'
    };
    var response = await http.post(EmailService.apiBase,
        body: jsonEncode(body), headers: EmailService.headers);
    print(response.body);
  }
}
