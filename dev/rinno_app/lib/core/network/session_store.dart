abstract interface class SessionStore {
  bool get usesCookies;
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);
  Future<void> clear();
}
