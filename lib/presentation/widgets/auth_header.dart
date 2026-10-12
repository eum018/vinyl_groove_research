import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// 로그인·회원가입 위쪽 흐린 배경 (+ 로고)
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.logo = true});

  final bool logo;

  @override
  Widget build(BuildContext context) => Container(
    height: 300,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/background.png'),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      color: AppColor.dim,
      alignment: const Alignment(0, .6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: logo ? const AuthLogo(width: 180) : const SizedBox(),
      ),
    ),
  );
}

/// 로고 + 영문 한 줄
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: Gap.s,
    children: [
      Image.asset('assets/logo_horizontal.png', width: width),
      AppText.regular(
        12,
        AppColor.whiteL1,
      ).text('Vinyl Record Secondhand Marketplace'),
    ],
  );
}

/// "로그인" + 설명 한 줄
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.s,
    children: [
      AppText.bold(24).text(title),
      AppText.regular(14, AppColor.whiteL1).text(subtitle),
    ],
  );
}
