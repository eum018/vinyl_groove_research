import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_icon.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';

/// 검색창 오른쪽 바코드 버튼: 찍거나 입력 → 상품 상세로
class BarcodeButton extends StatelessWidget {
  const BarcodeButton({super.key});

  Future<void> _scan(BuildContext context) async {
    final code = await context.go<String>(Routes.barcode);
    if (code == null || !context.mounted) return;

    final barcode = code.padLeft(13, '0');
    final res = await context.deps.products.byBarcode(barcode);
    if (!context.mounted) return;
    switch (res) {
      case Ok(:final value) when value.isEmpty:
        Native.toast('바코드 "$barcode"에\n해당하는 상품을 찾을 수 없습니다');
      case Ok(:final value):
        context.go(Routes.album, value.first.id);
      case Err(:final message):
        Native.toast(message);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () => _scan(context),
    icon: AppIcon.barcode.icon(color: AppColor.whiteL1, size: 26),
  );
}
