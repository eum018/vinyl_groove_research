import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_icon.dart';
import '../../core/format.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/album_thumb.dart';
import '../../core/widgets/title_app_bar.dart';
import '../../data/stores/alert_store.dart';
import '../../domain/models.dart';

/// 서버가 준 안내 문구를 그대로 보여준다
void _toast(Result<void> res) => Native.toast(switch (res) {
  Ok(:final message) => message,
  Err(:final message) => message,
});

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = context.deps.alerts;
    return ListenableBuilder(
      listenable: alerts,
      builder: (context, _) => SafeArea(
        child: Scaffold(
          appBar: TitleAppBar(
            title: '알림',
            actions: [if (alerts.items.isNotEmpty) _Menu(alerts)],
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColor.background,
          body: RefreshIndicator(
            onRefresh: alerts.refresh,
            child: alerts.items.isEmpty
                ? const EmptyState(
                    icon: AppIcon.notification,
                    title: '알림이 없습니다.',
                    subtitle: '관심 상품의 가격이 변경되면 알려드릴게요.',
                    scrollable: true,
                  )
                : _AlertList(alerts),
          ),
        ),
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList(this.alerts);

  final AlertStore alerts;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final a in alerts.items)
        _AlertTile(key: ValueKey(a.id), alert: a, store: alerts),
    ],
  );
}

/// ⋮ 메뉴: 모두 읽음 · 전체 삭제
class _Menu extends StatelessWidget {
  const _Menu(this.alerts);

  final AlertStore alerts;

  Future<void> _deleteAll(BuildContext context) async {
    final ok = await AppConfirmDialog.show(
      context,
      title: '알림 전체 삭제',
      confirm: '삭제',
    );
    if (ok) _toast(await alerts.deleteAll());
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton(
    key: const Key('alerts_menu'),
    color: AppColor.blackL2,
    padding: const EdgeInsets.symmetric(horizontal: Gap.s),
    itemBuilder: (context) => [
      PopupMenuItem(
        onTap: () => alerts.read(all: true).then(_toast),
        child: AppText.regular(14).text('모두 읽음'),
      ),
      PopupMenuItem(
        onTap: () => _deleteAll(context),
        child: AppText.regular(14, AppColor.red).text('전체 삭제'),
      ),
    ],
    child: const Icon(Icons.more_vert, color: AppColor.white),
  );
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({super.key, required this.alert, required this.store});

  final AlertModel alert;
  final AlertStore store;

  @override
  Widget build(BuildContext context) => Material(
    clipBehavior: Clip.hardEdge,
    color: alert.isRead ? AppColor.background : AppColor.yellow.withAlpha(12),
    child: InkWell(
      onTap: () {
        store.read(id: alert.id).then(_toast);
        context.go(Routes.album, alert.productId);
      },
      child: Padding(
        padding: const EdgeInsets.all(Gap.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Gap.m,
          children: [
            AlbumThumb(alert.albumImage, size: 72),
            Expanded(child: _AlertText(alert)),
            Row(
              spacing: Gap.s,
              children: [
                AppText.regular(
                  12,
                  AppColor.whiteL3,
                ).text(Fmt.ago(alert.createdAt)),
                if (!alert.isRead)
                  const CircleAvatar(
                    backgroundColor: AppColor.yellow,
                    radius: 4,
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _AlertText extends StatelessWidget {
  const _AlertText(this.alert);

  final AlertModel alert;

  @override
  Widget build(BuildContext context) {
    final color = alert.isPriceDown ? AppColor.green : AppColor.red;
    final was = AppText.regular(12, AppColor.whiteL1).copyWith(
      decoration: TextDecoration.lineThrough,
      decorationColor: AppColor.whiteL1,
      decorationThickness: 1.5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Gap.xs,
      children: [
        Row(
          spacing: Gap.s,
          children: [
            Icon(
              alert.isPriceDown ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 18,
            ),
            AppText.medium(13, color).text(alert.title),
          ],
        ),
        (alert.isRead ? AppText.regular(15) : AppText.bold(15)).text(
          alert.albumName,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          spacing: Gap.s,
          children: [
            was.text(Fmt.wonSpaced(alert.previousPrice)),
            const Icon(Icons.arrow_forward, color: AppColor.whiteL1, size: 14),
            AppText.bold(
              15,
              AppColor.yellow,
            ).text(Fmt.wonSpaced(alert.currentPrice)),
          ],
        ),
      ],
    );
  }
}
