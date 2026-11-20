import 'package:flutter/foundation.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

/// Implementation of Pinput's [SmsRetriever] using [SmartAuth].
class SmsRetrieverImpl implements SmsRetriever {
  final SmartAuth smartAuth;

  const SmsRetrieverImpl(this.smartAuth);

  @override
  Future<void> dispose() async {
    try {
      await smartAuth.removeUserConsentApiListener();
    } catch (e) {
      debugPrint('Error removing SMS listener: $e');
    }
  }

  @override
  Future<String?> getSmsCode() async {
    try {
      final res = await smartAuth.getSmsWithUserConsentApi();
      if (res.hasData) {
        return res.data?.code;
      }
    } catch (e) {
      debugPrint('Error retrieving SMS code: $e');
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}
