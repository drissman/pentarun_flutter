import 'package:gotrue/gotrue.dart';

/// Stub non-web — ne devrait jamais être instancié sur mobile.
class WebGotrueAsyncStorage extends GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async => null;
  @override
  Future<void> removeItem({required String key}) async {}
  @override
  Future<void> setItem({required String key, required String value}) async {}
}
