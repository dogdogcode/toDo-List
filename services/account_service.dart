class AccountService {
  static final AccountService _instance = AccountService._internal();

  factory AccountService() {
    return _instance;
  }

  AccountService._internal();

  // 계정 동기화: 실제 네트워크 호출 대신 시뮬레이션
  Future<Map<String, dynamic>> syncAccount() async {
    // ...existing code (예: API 호출 최적화)...
    await Future.delayed(const Duration(seconds: 1));
    return {'username': '동기화된 사용자 이름', 'email': 'user@example.com'};
  }
}
