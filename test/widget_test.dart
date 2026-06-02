import 'package:flutter_test/flutter_test.dart';
import 'package:vacansa/core/utils/email_topic_sanitizer.dart';

void main() {
  test('app smoke - sanitizer', () {
    expect(sanitizeEmailForTopic('a@b.co'), isNotEmpty);
  });
}
