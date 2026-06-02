/// Sanitizes email for FCM topic names (allowed: [a-zA-Z0-9-_.~%]+).
String sanitizeEmailForTopic(String email) {
  final normalized = email.trim().toLowerCase();
  final buffer = StringBuffer();
  for (final code in normalized.runes) {
    final ch = String.fromCharCode(code);
    if (RegExp(r'[a-z0-9\-_.~%]').hasMatch(ch)) {
      buffer.write(ch);
    } else if (ch == '@') {
      buffer.write('_at_');
    } else {
      buffer.write('_');
    }
  }
  var topic = buffer.toString();
  while (topic.contains('__')) {
    topic = topic.replaceAll('__', '_');
  }
  topic = topic.replaceAll(RegExp(r'^_|_$'), '');
  if (topic.length > 900) {
    topic = topic.substring(0, 900);
  }
  return topic.isEmpty ? 'user_unknown' : topic;
}
