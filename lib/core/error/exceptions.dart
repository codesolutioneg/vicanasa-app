class ServerException implements Exception {
  ServerException([this.message = 'Server error']);
  final String message;
}

class NetworkException implements Exception {
  NetworkException([this.message = 'Network error']);
  final String message;
}

class AuthException implements Exception {
  AuthException([this.message = 'Auth failed']);
  final String message;
}
