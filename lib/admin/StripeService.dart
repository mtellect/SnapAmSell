import 'dart:convert';

import 'package:Strokes/assets.dart';
import 'package:Strokes/basemodel.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  Map<String, dynamic> body;
  StripeTransactionResponse({this.message, this.success, this.body});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secret = appSettingsModel.getString(STRIPE_SEC_KEY);
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey: appSettingsModel.getString(STRIPE_PUB_KEY),
        merchantId: "merchant.fetish.app",
        androidPayMode: 'test,'));
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

  static Future<BaseModel> doConversion(double amount,
      {double adsRunFor = 1.0, double adsCostPerDay = 1.0}) async {
    String baseCurrency = appSettingsModel.getString(APP_CURRENCY);
    String baseCurrencyName = appSettingsModel.getString(APP_CURRENCY_NAME);
    String myCountry = userModel.getString(COUNTRY);

    final apiKey = "c4539a5b787cd95c601c";
    String countryUrl = "https://restcountries.eu/rest/v2/name/$myCountry";
    var response = await http.get(countryUrl);
    final model = BaseModel(items: jsonDecode(response.body)[0]);
    final currency = model.getListModel("currencies");
    String code = currency[0].getString("code");
    String symbol = currency[0].getString("symbol");
    String conKey = "${baseCurrency}_$code";
    String conBaseUrl = "https://free.currconv.com/api/v7/convert";
    String conversionUrl = "$conBaseUrl?q=$conKey&compact=ultra&apiKey=$apiKey";
    var response2 = await http.get(conversionUrl);
    Map perUnitData = jsonDecode(response2.body);
    final perUnitValue = perUnitData[conKey];

    double localAdsCost =
        (/*adsRunFor * adsCostPerDay*/ amount * perUnitValue).roundToDouble();
    //double baseAdsCost = (/*adsRunFor*/ amount * adsCostPerDay).roundToDouble();
    String yourPaying = "($symbol$localAdsCost)";
    print("Ads Costs $localAdsCost");

    BaseModel bm = BaseModel();
    bm.put(LOCAL_ADS_COST, localAdsCost);
    bm.put(LOCAL_ADS_COST, amount);
    bm.put(AMOUNT_TO_PAY, yourPaying);

    return bm;
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
}
