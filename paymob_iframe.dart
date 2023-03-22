import 'dart:developer';
import 'dart:io';

import 'package:eshop/main.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'paymob_response.dart';

class PaymobIFrame extends StatefulWidget {
  const PaymobIFrame({Key? key, required this.redirectURL, required this.onPayment}) : super(key: key);

  final String redirectURL;
  final Function() onPayment;

  static Future<PaymobResponse?> show({
    required String redirectURL,
    required Function() onPayment,
  }) => Navigator.of(appContext).push(
    MaterialPageRoute(
      builder: (context) {
        return PaymobIFrame(
          onPayment: onPayment,
          redirectURL: redirectURL,
        );
      },
    ),
  );

  @override
  State<PaymobIFrame> createState() => _PaymobIFrameState();
}

class _PaymobIFrameState extends State<PaymobIFrame> {

  @override
  void initState() {
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: widget.redirectURL,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          if (request.url.contains('txn_response_code') &&
              request.url.contains('success') &&
              request.url.contains('id')) {
            final params = _getParamFromURL(request.url);
            Navigator.pop(context, PaymobResponse.fromJson(params));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (error) {
          print(error.errorType);
          print(error.description);
          print(error.domain);
          print(error.failingUrl);
        },
      ),
    );
  }

  Map<String, dynamic> _getParamFromURL(String url) {
    final uri = Uri.parse(url);
    Map<String, dynamic> data = {};
    uri.queryParameters.forEach((key, value) {
      data[key] = value;
    });
    return data;
  }

}
