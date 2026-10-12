import 'package:flutter/material.dart';

import 'app_icon.dart';

/// 색 한 벌. 화면에서 Color(0x...)·Colors.white60을 직접 쓰지 않는다.
abstract final class AppColor {
  static const black = Colors.black;
  static const background = Color(0xff121212);
  static const blackL1 = Color(0xff101113);
  static const blackL2 = Color(0xff1E1E1E);
  static const blackL3 = Color(0xff2A2A2A);
  static const yellow = Color(0xffD4A54B);
  static const red = Colors.red;
  static const green = Colors.green;

  static const white = Colors.white;
  static const whiteL1 = Colors.white60;
  static const whiteL3 = Colors.white30;
  static const whiteL4 = Colors.white10;
  static const dim = Colors.black54;
  static const badge = Color(0xb4000000); // Colors.black.withAlpha(180)
}

/// 간격 한 벌. spacing: 8 대신 spacing: Gap.s
abstract final class Gap {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// 글자 스타일 한 벌. TextStyle(을 화면에서 직접 쓰지 않는다.
abstract final class AppText {
  /// color를 null로 주면 버튼 글자색(foregroundColor)을 따른다
  static TextStyle bold(double size, [Color? color = AppColor.white]) =>
      TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold);

  static TextStyle medium(double size, [Color? color = AppColor.white]) =>
      TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w500);

  static TextStyle regular(double size, [Color? color = AppColor.white]) =>
      TextStyle(color: color, fontSize: size);

  // 크기를 정하지 않는 것들 — 자리마다 Flutter 기본 크기를 따른다 (입력창 16, 앱바 제목 22)
  static const input = TextStyle(color: AppColor.white);
  static const hint = TextStyle(color: AppColor.whiteL1);
  static const title = TextStyle(
    color: AppColor.white,
    fontWeight: FontWeight.bold,
  );
  static const dark = TextStyle(color: AppColor.black); // 흰 팝업 위 글자
}

extension TextOf on TextStyle {
  Text text(String s, {TextAlign? align, TextOverflow? overflow}) =>
      Text(s, style: this, textAlign: align, overflow: overflow);
}

/// 입력창·버튼 모양 한 벌.
abstract final class AppStyle {
  static final _radius = BorderRadius.circular(12);

  static InputDecoration input({
    String? hint,
    String? error,
    AppIcon? icon,
    Widget? suffix,
  }) => InputDecoration(
    filled: true,
    fillColor: AppColor.blackL1,
    counterText: '',
    hintText: hint,
    hintStyle: AppText.hint,
    errorText: error,
    errorMaxLines: 2,
    prefixIcon: icon == null
        ? null
        : Padding(
            padding: const EdgeInsets.all(11),
            child: icon.icon(color: AppColor.whiteL1),
          ),
    suffixIcon: suffix,
    border: OutlineInputBorder(borderRadius: _radius),
    focusedBorder: OutlineInputBorder(
      borderRadius: _radius,
      borderSide: const BorderSide(color: AppColor.yellow),
    ),
  );

  static final primary = ElevatedButton.styleFrom(
    backgroundColor: AppColor.yellow,
    foregroundColor: AppColor.black,
    shape: RoundedRectangleBorder(borderRadius: _radius),
    padding: const EdgeInsets.symmetric(vertical: 14),
  );

  static ButtonStyle chip(bool selected) => ElevatedButton.styleFrom(
    backgroundColor: selected ? AppColor.yellow : AppColor.blackL2,
    foregroundColor: selected ? AppColor.black : AppColor.white,
    minimumSize: Size.zero,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );

  static final panel = RoundedRectangleBorder(borderRadius: _radius);
}
