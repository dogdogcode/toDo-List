// Firebase 관련 코드를 모두 비활성화하여 항상 게스트 정보를 반환하도록 수정
class AccountService {
  static final AccountService _instance = AccountService._internal();

  factory AccountService() => _instance;

  AccountService._internal();

  Future<Map<String, dynamic>> syncAccount() async {
    // 가상의 지연을 위한 Future.delayed (타입 인수 명시)
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Firebase 코드 비활성화: 항상 게스트 사용자 정보를 반환
    return {'username': '게스트 사용자', 'email': 'guest@example.com'};
  }
}
