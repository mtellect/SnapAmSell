import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:maugost_apps/assets.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

typedef void OnUploadProgressCallback(int sentBytes, int totalBytes);

class StripeTransactionResponse {
  String message;
  bool success;
  Map<String, dynamic> body;
  StripeTransactionResponse({this.message, this.success, this.body});
}

class StripeService {
  static String _apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService._apiBase}/payment_intents';
  static String _accountApiUrl = '${StripeService._apiBase}/accounts';
  static String _customerApiUrl = '${StripeService._apiBase}/customers';
  static String _tokenApiUrl = '${StripeService._apiBase}/tokens';
  static String _transfersApiUrl = '${StripeService._apiBase}/transfers';
  static String _files = '${StripeService._apiBase}/files';
  static String _secret = appSettingsModel.getString(STRIPE_SEC_KEY);
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService._secret}',
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  static init() {
    String mAndroid = appSettingsModel.getString(STRIPE_MERCHANT_ANDROID);
    String mIOS = appSettingsModel.getString(STRIPE_MERCHANT_ANDROID);
    String pubKey = appSettingsModel.getString(STRIPE_PUB_KEY);
    String payMode = appSettingsModel.getString(STRIPE_MODE);
    Stripe.init(pubKey, returnUrlForSca: "stripesdk://3ds.stripesdk.io");

    StripePayment.setOptions(StripeOptions(
        publishableKey: pubKey,
        merchantId: Platform.isAndroid ? mAndroid : mIOS,
        androidPayMode: payMode));
  }

  static Future<StripeTransactionResponse> payViaExistingCard(
      {String amount, String currency, CreditCard card}) async {
    try {
      var paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: card));
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true,
            body: response.toJson());
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static Future<StripeTransactionResponse> payWithNewCard(
      {String amount, String currency}) async {
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true,
            body: response.toJson());
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(message: message, success: false);
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(StripeService.paymentApiUrl,
          body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }

  static Future<StripeTransactionResponse> payWithNative(
      {String amount, String currency}) async {
    print("Native");
    try {
      bool deviceSupportNativePay =
          await StripePayment.deviceSupportsNativePay();

      bool isNativeReady = await StripePayment.canMakeNativePayPayments(
          ['american_express', 'visa', 'maestro', 'master_card']);

      if (!deviceSupportNativePay && !isNativeReady)
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);

      var pay = await StripePayment.paymentRequestWithNativePay(
          androidPayOptions: AndroidPayPaymentRequest(
            totalPrice: "1.20",
            currencyCode: "EUR",
          ),
          applePayOptions: ApplePayPaymentOptions(
              countryCode: 'DE',
              currencyCode: 'EUR',
              items: [
                ApplePayItem(
                  label: "Hello",
                  amount: amount,
                )
              ]));

      print(pay.tokenId);
      //return null;

      var paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(token: pay));
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true,
            body: response.toJson());
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static createStripeCustomer(
      {String country, onResponse(StripeTransactionResponse resp)}) async {
    Map<String, dynamic> body = {
      'country': 'US',
      'type': 'custom',
      'requested_capabilities[]': 'card_payments',
      'requested_capabilities[]': 'transfers',
      //'business_type': 'individual',
      //'individual[first_name] ': userModel.getUserName()
    };
    http
        .post(StripeService._accountApiUrl,
            body: body, headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Customer response $response\n");
      onResponse(StripeTransactionResponse(
          body: response, message: "Account Created", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static createStripePerson(
      {String personId,
      @required String bDay,
      @required String bMonth,
      @required String bYear,
      @required String path,
      @required String ssNumber,
      @required String email,
      @required String firstName,
      @required String lastName,
      @required onResponse(StripeTransactionResponse resp)}) async {
    Map<String, dynamic> body = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'id_number': ssNumber
    };

    String customerId = userModel.getString(STRIPE_ACCOUNT_ID);
    String url = StripeService._accountApiUrl + '/$customerId/persons';
    if (personId.isNotEmpty) url = url + '/$personId';

    http.post(url, body: body, headers: StripeService.headers).then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Person response $response\n");
      userModel
        ..put(STRIPE_PERSON_ID, response["id"])
        ..updateItems();
      String accountId = userModel.getString(STRIPE_ACCOUNT_ID);

      Map<String, dynamic> body = {
        'legal_entity[type]': 'individual',
        'legal_entity[ssn_last_4]': ssNumber,
        'legal_entity[first_name]': firstName,
        'legal_entity[last_name]': lastName,
        'legal_entity[dob][day]': bDay,
        'legal_entity[dob][month]': bMonth,
        'legal_entity[dob][year]': bYear,
        'business_url': 'www.ponos.app/${userModel.getUserName()}',
      };
      updateStripeAccount(
          body: body,
          onResponse: (resp) {
            if (!resp.success) {
              onResponse(StripeTransactionResponse(
                  message: resp.message, success: false));
              return;
            }

            userModel
              ..put(BIRTH_DATE, '$bYear-$bMonth-$bDay')
              ..put(SS_NUMBER, ssNumber)
              ..put(FIRST_NAME, firstName)
              ..put(LAST_NAME, lastName)
              ..updateItems();

            _documentVerification(
                customerId: accountId,
                personId: response['id'],
                path: path,
                onResponse: onResponse);
          });
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static createStripeBankToken(
      {@required String accountName,
      @required String bankName,
      @required String routingNumber,
      @required String accountNumber,
      @required onResponse(StripeTransactionResponse resp)}) async {
    Map<String, dynamic> body = {
      "bank_account[country]": 'US',
      "bank_account[currency]": 'usd',
      "bank_account[account_holder_name]": accountName,
      "bank_account[account_holder_type]": 'individual',
      "bank_account[routing_number]": routingNumber,
      "bank_account[account_number]": accountNumber
    };
    http
        .post(StripeService._tokenApiUrl,
            body: body, headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: msg, //"Msg $msg \nType $type \nParam $param",
            success: false));
        return;
      }
      print("Stripe Bank Token response $response\n");
      String bankToken = response['id'];
      userModel
        ..put(ROUTING_NUMBER, routingNumber)
        ..put(ACCOUNT_NUMBER, accountNumber)
        ..put(ACCOUNT_NAME, accountName)
        ..put(BANK_NAME, bankName)
        //..put(STRIPE_BANK_TOKEN, bankToken)
        ..updateItems();
      _createStripeBankAccount(bankToken: bankToken, onResponse: onResponse);
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static _createStripeBankAccount(
      {@required String bankToken,
      @required onResponse(StripeTransactionResponse resp)}) async {
    https: //api.stripe.com/v1/accounts/acct_1032D82eZvKYlo2C/external_accounts

    Map<String, dynamic> body = {
      "external_account": bankToken,
    };
    String customerId = userModel.getString(STRIPE_ACCOUNT_ID);
    http
        .post(StripeService._accountApiUrl + '/$customerId/external_accounts',
            body: body, headers: headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Bank Account response $response");
      userModel
        ..put(STRIPE_BANK_TOKEN, response['id'])
        ..put(STRIPE_PAYMENT_READY, true)
        ..updateItems();
      onResponse(StripeTransactionResponse(
          body: response, message: "Payout setup is complete", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static updateStripeAccount(
      {@required Map<String, dynamic> body,
      @required onResponse(StripeTransactionResponse resp)}) async {
    String accountId = userModel.getString(STRIPE_ACCOUNT_ID);
    print("Account id $accountId");

    http
        .post(StripeService._accountApiUrl + '/' + accountId,
            body: body, headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        print("Stripe error body ${resp.body}\n");
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      //print("Stripe Acceptance response $response\n");
      onResponse(StripeTransactionResponse(
          body: response, message: "Terms Accepted", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static fetchStripeAccount(
      {String accountId, onResponse(StripeTransactionResponse resp)}) async {
    print("Account id $accountId");

    http
        .get(StripeService._accountApiUrl + '/$accountId/capabilities',
            headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);

      if (resp.statusCode == 400 || response.containsKey("error")) {
        print("Stripe error body ${resp.body}\n");
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      onResponse(StripeTransactionResponse(
          body: response, message: "Terms Accepted", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static deleteStripeAccount(
      {String accountId, onResponse(StripeTransactionResponse resp)}) async {
    print("Account id $accountId");

    http
        .delete(StripeService._accountApiUrl + '/' + accountId,
            headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);

      if (resp.statusCode == 400 || response.containsKey("error")) {
        print("Stripe error body ${resp.body}\n");
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Acceptance response $response\n");
      onResponse(StripeTransactionResponse(
          body: response, message: "Terms Accepted", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static updateStripeAcceptance(
      {onResponse(StripeTransactionResponse resp)}) async {
    String accountId = userModel.getString(STRIPE_ACCOUNT_ID);
    String ipAddress = await _fetchMyIpAddress();
    print(ipAddress);
    final date = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> body = {
      "tos_acceptance[date]": (date / 1000).round().toString(),
      "tos_acceptance[ip]": ipAddress,
    };
    http
        .post(StripeService._accountApiUrl + '/' + accountId,
            body: body, headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Acceptance response $response\n");
      onResponse(StripeTransactionResponse(
          body: response, message: "Terms Accepted", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static checkStripeAcceptance(
      {@required onResponse(StripeTransactionResponse resp)}) async {
    String accountId = userModel.getString(STRIPE_ACCOUNT_ID);
    http
        .get(StripeService._accountApiUrl + '/' + accountId,
            //body: body,
            headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];
        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Check Acceptance response $response\n");

      onResponse(StripeTransactionResponse(
          body: response, message: "Account Created", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static _documentVerification(
      {@required String customerId,
      @required String personId,
      @required String path,
      @required onResponse(StripeTransactionResponse resp)}) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse("https://files.stripe.com/v1/files"));
    final file = await http.MultipartFile.fromPath('file', path,
        filename: "VerificationDoc");
    request.files.add(file);
    request.fields.addAll({'purpose': 'identity_document'});
    request.headers.addAll(
      {
        'Authorization': 'Bearer ${StripeService._secret}',
        'Content-Type': 'application/json',
      },
    );

    request.send().then((resp) {
      resp.stream.transform(utf8.decoder).listen((value) {
        Map response = jsonDecode(value);
        if (resp.statusCode == 400 || response.containsKey("error")) {
          final msg = response["error"]["message"];
          final param = response["error"]["param"];
          final type = response["error"]["type"];
          onResponse(StripeTransactionResponse(
              message: "Msg $msg \nType $type \nParam $param", success: false));
          return;
        }
        print("Stripe Doc Verification response $response\n");
        _confirmDocOnStripe(
            accountId: customerId,
            personId: personId,
            fileId: response['id'],
            onResponse: onResponse);
      });
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static _confirmDocOnStripe(
      {@required String accountId,
      @required String personId,
      @required String fileId,
      @required onResponse(StripeTransactionResponse resp)}) async {
    //String accountId = userModel.getString(STRIPE_ACCOUNT_ID);
    //String personId = userModel.getString(STRIPE_PERSON_ID);
    Map<String, dynamic> body = {
      "verification[document][front]": fileId,
    };
    http
        .post(StripeService._accountApiUrl + '/$accountId/persons/$personId',
            body: body, headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];

        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Confirm Doc response $response\n");
      onResponse(StripeTransactionResponse(
          body: response, message: "Terms Accepted", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static createTransfer(
      {@required double amount,
      @required onResponse(StripeTransactionResponse resp)}) async {
    String accountId = userModel.getString(STRIPE_ACCOUNT_ID);
    Map<String, dynamic> body = {
      'amount': (100 * amount.round()).toString(),
      'currency': 'usd',
      'destination': accountId,
    };
    http
        .post(StripeService._transfersApiUrl,
            body: body, headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];

        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Confirm Doc response $response\n");
      onResponse(StripeTransactionResponse(
          body: response, message: "Terms Accepted", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static fetchTransfer(
      {@required String transferId,
      @required onResponse(StripeTransactionResponse resp)}) async {
    http
        .get(StripeService._transfersApiUrl + '/$transferId',
            headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];

        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Confirm Doc response $response\n");
      onResponse(StripeTransactionResponse(
          body: response, message: "Terms Accepted", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static updateTransfer(
      {@required Map<String, dynamic> body,
      @required String transferId,
      @required onResponse(StripeTransactionResponse resp)}) async {
    http
        .post(StripeService._transfersApiUrl + '/$transferId',
            body: body, headers: StripeService.headers)
        .then((resp) {
      Map response = jsonDecode(resp.body);
      if (resp.statusCode == 400 || response.containsKey("error")) {
        final msg = response["error"]["message"];
        final param = response["error"]["param"];
        final type = response["error"]["type"];

        onResponse(StripeTransactionResponse(
            message: "Msg $msg \nType $type \nParam $param", success: false));
        return;
      }
      print("Stripe Confirm Doc response $response\n");
      onResponse(StripeTransactionResponse(
          body: response, message: "Terms Accepted", success: true));
    }).catchError((e) {
      onResponse(
          StripeTransactionResponse(message: e.toString(), success: false));
    });
  }

  static Future<String> _fetchMyIpAddress() async {
    print("Fetching IP Address");
    final resp = await http.get('https://api.ipify.org?format=json');
    return jsonDecode(resp.body)["ip"];
  }
}
