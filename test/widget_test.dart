import 'package:flutter_test/flutter_test.dart';
import 'package:scorefusion/constants/app_constants.dart';

void main() {
  test('app constants are configured', () {
    expect(AppConstants.webUrl, contains('getscorefusion.com'));
    expect(AppConstants.appName, 'Score Fusion');
    expect(AppConstants.blockedUrls, isNotEmpty);
  });
}