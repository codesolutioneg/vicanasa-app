import 'package:flutter_test/flutter_test.dart';
import 'package:vacansa/core/utils/email_topic_sanitizer.dart';

void main() {
  test('sanitizes email for FCM topic', () {
    expect(
      sanitizeEmailForTopic('User@Example.com'),
      'user_at_example.com',
    );
  });
}
