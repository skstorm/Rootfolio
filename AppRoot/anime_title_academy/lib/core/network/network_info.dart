abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  // TODO: 이후 internet_connection_checker 등의 패키지로 실제 구현 교체 가능
  @override
  Future<bool> get isConnected async {
    return true; // 일단 항상 연결 상태라고 가정 (MVP 단계 Mock 역할)
  }
}
