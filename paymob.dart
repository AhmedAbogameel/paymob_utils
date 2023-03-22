import 'dart:developer';

import 'package:dio/dio.dart';

import 'paymob_iframe.dart';
import 'paymob_response.dart';

class PaymobUtils {
  static PaymobUtils instance = PaymobUtils();

  static bool _isInitialised = false;

  final Dio _dio = Dio();
  static const _baseURL = 'https://accept.paymob.com/api/';
  static const _apiKey = '';
  static const _integrationID = 3360056;
  static const _iFrameID = 728319;
  static const _iFrameURL = 'https://accept.paymobsolutions.com/api/acceptance/iframes/$_iFrameID?payment_token=';
      // 'https://accept.paymob.com/api/acceptance/iframes/$_iFrameID?payment_token=';

  PaymobUtils() {
    if (!_isInitialised) {
      init();
    }
  }

  Future<bool> init() async {
    _dio.options.baseUrl = _baseURL;
    _dio.options.validateStatus = (status) => true;
    _isInitialised = true;
    return _isInitialised;
  }

  Future<String> getAuthToken() async {
    try {
      final response = await _dio.post(
        'auth/tokens',
        data: {
          'api_key': _apiKey,
        },
      );
      return response.data['token'];
    } catch (e) {
      rethrow;
    }
  }

  Future<int> addOrder({
    required String authToken,
    required String currency,
    required String amount,
  }) async {
    try {
      final response = await _dio.post(
        'ecommerce/orders',
        data: {
          "auth_token": authToken,
          "delivery_needed": "false",
          "amount_cents": amount,
          "currency": currency,
          "items": [],
        },
      );
      return response.data['id'];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getPurchaseToken(
      {required String authToken,
      required String currency,
      required int orderID,
      required String amount}) async {
    final response = await _dio.post(
      'acceptance/payment_keys',
      data: {
        "auth_token": authToken,
        "amount_cents": amount,
        "expiration": 3600,
        "order_id": orderID,
        "billing_data": {
          "apartment": "00000",
          "email": "example@mail.com",
          "floor": "000",
          "first_name": "Unknown",
          "street": "Unknown",
          "building": "00000",
          "phone_number": "+9612341234",
          "shipping_method": "Unknown",
          "postal_code": "00000",
          "city": "NA",
          "country": "NA",
          "last_name": "NA",
          "state": "NA"
        },
        "currency": currency,
        "integration_id": _integrationID,
        "lock_order_when_paid": "false"
      },
    );
    return response.data['token'];
  }

  Future<PaymobResponse?> pay({required String currency, required String amount}) async {
    final authToken = await getAuthToken();
    final orderID = await addOrder(
      authToken: authToken,
      currency: currency,
      amount: amount,
    );
    final purchaseToken = await getPurchaseToken(
      authToken: authToken,
      currency: currency,
      orderID: orderID,
      amount: amount,
    );
    final response = await PaymobIFrame.show(
      redirectURL: _iFrameURL + purchaseToken,
      onPayment: () => print('onPayment'),
    );
    return response;
  }
}
