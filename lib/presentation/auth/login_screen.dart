import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_icon.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/link_row.dart';
import '../../core/widgets/or_divider.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/submit_button.dart';
import '../../domain/validators.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  Future<void> _login() async {
    setState(() {
      _emailError = Validators.loginEmail(_email.text);
      _passwordError = Validators.loginPassword(_password.text);
    });
    if (_emailError != null || _passwordError != null) return;

    final res = await context.deps.session.login(_email.text, _password.text);
    if (!mounted) return;
    switch (res) {
      case Ok():
        context.reset(Routes.nav); // 뒤로 가기로 로그인 화면에 돌아오지 않는다
      case Err(:final message):
        Native.toast(message);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.black,
      body: Column(
        children: [
          const AuthHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Gap.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Gap.l,
                children: [
                  const AuthTitle(
                    title: '로그인',
                    subtitle: '계정으로 로그인하여 다양한 서비스를 이용하세요.',
                  ),
                  const SizedBox(),
                  AppTextField(
                    key: const Key('login_email'),
                    controller: _email,
                    hint: '이메일을 입력해주세요.',
                    icon: AppIcon.email,
                    error: _emailError,
                  ),
                  PasswordField(
                    key: const Key('login_password'),
                    controller: _password,
                    hint: '비밀번호를 입력해주세요.',
                    error: _passwordError,
                  ),
                  const _ForgotPassword(),
                  SubmitButton(
                    key: const Key('login_submit'),
                    label: '로그인',
                    onPressed: _login,
                  ),
                  const OrDivider(),
                  LinkRow(
                    key: const Key('login_to_signup'),
                    question: '계정이 없으신가요?',
                    action: '회원가입',
                    onPressed: () => context.go(Routes.signup),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ForgotPassword extends StatelessWidget {
  const _ForgotPassword();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () => Native.notReady('비밀번호 찾기'),
      child: AppText.medium(14, AppColor.whiteL1).text('비밀번호를 잊으셨나요?'),
    ),
  );
}
