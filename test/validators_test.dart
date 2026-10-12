import 'package:flutter_test/flutter_test.dart';
import 'package:vinyl_groove/domain/validators.dart';

void main() {
  test('로그인 이메일: 맞는 형식은 통과, "@" 앞에 "."이 있으면 실패', () {
    expect(Validators.loginEmail('user@test.com'), isNull);
    expect(Validators.loginEmail(''), '이메일은 필수 입니다.');
    expect(Validators.loginEmail('a.b@test.com'), isNotNull);
  });

  test('회원가입 비밀번호: 대문자·소문자를 따로 요구한다', () {
    expect(Validators.signupPassword('Abcdef1!'), isNull);
    expect(Validators.signupPassword('abcdef1!'), isNotNull); // 대문자 없음
    expect(Validators.signupPassword('Ab1!'), '비밀번호는 필수 값으로써 8자 이상이어야 합니다.');
  });

  test('이름: 한글·영문만 통과', () {
    expect(Validators.name('홍길동'), isNull);
    expect(Validators.name('Hong'), isNull);
    expect(Validators.name('홍길동1'), '이름은 필수 값으로써 한글 또는 영문만 입력 가능합니다.');
  });

  test('휴대폰: 숫자가 아니면 실패', () {
    expect(Validators.phone(['010', '1234', '5678']), isNull);
    expect(Validators.phone(['010', '12a4', '5678']), isNotNull);
  });

  test('메시지 따옴표는 곧은 따옴표만 쓴다', () {
    final msg = Validators.loginEmail('x')!;
    expect(msg.contains(RegExp('[“”]')), isFalse);
  });
}
