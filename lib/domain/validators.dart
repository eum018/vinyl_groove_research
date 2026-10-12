/// 입력 검증 규칙과 에러 문구는 전부 여기. null이면 통과.
abstract final class Validators {
  static final _email = RegExp(r'^[^.]*@.*\..*$');
  static final _upperLower = RegExp(r'(?=.*[A-Z])(?=.*[a-z])');
  static final _digitSpecial = RegExp(r'(?=.*[0-9])(?=.*[!@#$%^&*])');
  static final _notName = RegExp(r'[^A-Za-zㄱ-ㅎㅏ-ㅣ가-힣]+');
  static final _notDigit = RegExp(r'\D+');

  // ── 로그인 ──
  static String? loginEmail(String v) {
    if (v.isEmpty) return '이메일은 필수 입니다.';
    if (!_email.hasMatch(v)) {
      return '이메일은 "@" 포함 "."포함 "@" 앞에 "."사용 불가의 형식을 따릅니다.';
    }
    return null;
  }

  static String? loginPassword(String v) {
    if (v.isEmpty) return '비밀번호는 필수 입니다.';
    if (v.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
    if (!_upperLower.hasMatch(v)) {
      return '비밀번호는 - 대문자 1자 이상 소문자 1자 이상의 형식을 따릅니다.';
    }
    return null;
  }

  // ── 회원가입 ──
  static String? signupEmail(String v) => _email.hasMatch(v)
      ? null
      : '이메일은 필수 값으로써 "@" 기호 포함 "." 기호 포함(도메인 영역에만)의 형식을 가집니다.';

  static String? signupPassword(String v) {
    if (v.length < 8) return '비밀번호는 필수 값으로써 8자 이상이어야 합니다.';
    // 대문자·소문자를 따로 요구한다 ([A-Za-z] 하나로는 "abc1!"이 통과한다)
    if (!_upperLower.hasMatch(v) || !_digitSpecial.hasMatch(v)) {
      return '비밀번호는 대/소문자, 숫자, 특수문자 각 1자 이상 포함해야 합니다.';
    }
    return null;
  }

  static String? passwordConfirm(String pw, String confirm) =>
      pw == confirm ? null : '비밀번호와 비밀번호 확인이 일치하지 않습니다.';

  static String? name(String v) {
    if (v.isEmpty) return '이름은 필수 값입니다.';
    if (_notName.hasMatch(v)) return '이름은 필수 값으로써 한글 또는 영문만 입력 가능합니다.';
    return null;
  }

  static String? phone(List<String> parts) =>
      parts.any(_notDigit.hasMatch) ? '휴대폰 번호는 숫자만 입력 가능합니다.' : null;
}
