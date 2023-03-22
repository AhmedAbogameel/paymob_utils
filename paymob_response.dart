class PaymobResponse {
  bool success;
  String? id;
  String? responseCode;
  String? message;

  PaymobResponse({
    this.id,
    required this.success,
    this.responseCode,
    this.message,
  });

  factory PaymobResponse.fromJson(Map<String, dynamic> json) {
    return PaymobResponse(
      success: json['success'] == 'true',
      id: json['id'],
      message: json['message'],
      responseCode: json['txn_response_code'],
    );
  }
}
