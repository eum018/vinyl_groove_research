import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_icon.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/form_section.dart';
import '../../core/widgets/link_row.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/submit_button.dart';
import '../../domain/validators.dart';
import '../widgets/auth_header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  final _phones = List.generate(3, (_) => TextEditingController());
  final _focus = List.generate(3, (_) => FocusNode());

  Map<String, String?> _errors = const {};
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    // 앞자리 3칸·가운데 4칸을 다 채우면 다음 칸으로
    for (final (i, max) in [(0, 3), (1, 4)]) {
      _phones[i].addListener(() {
        if (_phones[i].text.length == max) _focus[i].nextFocus();
      });
    }
  }

  Future<void> _signup() async {
    if (!_agreed) {
      Native.toast('이용약관 및 개인정보처리방침에 동의해 주세요.');
      return;
    }
    final phones = [for (final c in _phones) c.text];
    setState(() {
      _errors = {
        'email': Validators.signupEmail(_email.text),
        'password': Validators.signupPassword(_password.text),
        'confirm': Validators.passwordConfirm(_password.text, _confirm.text),
        'name': Validators.name(_name.text),
        'phone': Validators.phone(phones),
      };
    });
    if (_errors.values.any((e) => e != null)) return;

    final res = await context.deps.auth.signup(
      email: _email.text,
      password: _password.text,
      name: _name.text,
      phone: phones.join('-'),
    );
    if (!mounted) return;
    switch (res) {
      case Ok():
        Native.toast('회원가입이 완료되었습니다.');
        context.back();
      case Err(:final message):
        Native.toast(message); // 실패해도 알려준다
    }
  }

  @override
  void dispose() {
    for (final c in [_email, _password, _confirm, _name, ..._phones]) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SignupLayout(
    children: [
      const AuthTitle(title: '회원가입', subtitle: '회원 정보를 입력하여 계정을 만들어주세요.'),
      const SizedBox(),
      _AccountFields(this),
      FormSection(
        label: '이름',
        star: true,
        child: AppTextField(
          key: const Key('signup_name'),
          controller: _name,
          hint: '이름을 입력해주세요.',
          icon: AppIcon.person,
          error: _errors['name'],
        ),
      ),
      FormSection(
        label: '휴대폰 번호',
        star: true,
        error: _errors['phone'],
        errorSize: 12,
        child: _PhoneFields(controllers: _phones, focus: _focus),
      ),
      _Agree(value: _agreed, onTap: () => setState(() => _agreed = !_agreed)),
      SubmitButton(
        key: const Key('signup_submit'),
        label: '회원가입',
        onPressed: _signup,
      ),
      LinkRow(
        question: '이미 계정이 있으신가요?',
        action: '로그인',
        onPressed: () => context.back(),
      ),
    ],
  );
}

/// 이메일·비밀번호·비밀번호 확인
class _AccountFields extends StatelessWidget {
  const _AccountFields(this.s);

  final _SignupScreenState s;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.l,
    children: [
      FormSection(
        label: '이메일',
        star: true,
        child: AppTextField(
          key: const Key('signup_email'),
          controller: s._email,
          hint: '이메일을 입력해주세요.',
          icon: AppIcon.email,
          error: s._errors['email'],
        ),
      ),
      FormSection(
        label: '비밀번호',
        star: true,
        note: '8자 이상, 대소문자, 숫자, 특수문자 포함',
        child: PasswordField(
          key: const Key('signup_password'),
          controller: s._password,
          hint: '비밀번호를 입력해주세요.',
          error: s._errors['password'],
        ),
      ),
      FormSection(
        label: '비밀번호 확인',
        star: true,
        child: PasswordField(
          key: const Key('signup_confirm'),
          controller: s._confirm,
          hint: '비밀번호를 다시 입력해주세요.',
          error: s._errors['confirm'],
        ),
      ),
    ],
  );
}

/// 배경 + 뒤로 가기 + 로고 + 스크롤되는 입력 목록
class _SignupLayout extends StatelessWidget {
  const _SignupLayout({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.black,
      body: Stack(
        children: [
          const AuthHeader(logo: false),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: const Key('back'),
                onPressed: () => context.back(),
                icon: const Icon(Icons.arrow_back_ios, color: AppColor.white),
              ),
              Expanded(child: _Scroll(children)),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Scroll extends StatelessWidget {
  const _Scroll(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      children: [
        const SizedBox(height: 72),
        const Padding(
          padding: EdgeInsets.all(Gap.m),
          child: AuthLogo(width: 160),
        ),
        Padding(
          padding: const EdgeInsets.all(Gap.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Gap.l,
            children: children,
          ),
        ),
      ],
    ),
  );
}

/// 010 - 1234 - 5678
class _PhoneFields extends StatelessWidget {
  const _PhoneFields({required this.controllers, required this.focus});

  final List<TextEditingController> controllers;
  final List<FocusNode> focus;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final (i, (flex, max, hint)) in [
        (3, 3, '010'),
        (4, 4, '1234'),
        (4, 4, '5678'),
      ].indexed) ...[
        if (i > 0) const _Dash(),
        Expanded(
          flex: flex,
          child: AppTextField(
            key: Key('signup_phone_$i'),
            controller: controllers[i],
            focusNode: focus[i],
            maxLength: max,
            center: true,
            hint: hint,
          ),
        ),
      ],
    ],
  );
}

class _Dash extends StatelessWidget {
  const _Dash();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: Gap.xl,
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Divider(color: AppColor.white),
    ),
  );
}

class _Agree extends StatelessWidget {
  const _Agree({required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Gap.s),
    child: Row(
      children: [
        Checkbox(
          key: const Key('signup_agree'),
          activeColor: AppColor.yellow,
          side: const BorderSide(color: AppColor.white, width: 2),
          value: value,
          onChanged: (_) => onTap(),
        ),
        AppText.medium(14, AppColor.whiteL1).text('이용약관 및 개인정보처리방침에 동의합니다.'),
      ],
    ),
  );
}
