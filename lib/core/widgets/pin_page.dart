import 'package:flutter/material.dart';

import '../theme.dart';
import 'title_app_bar.dart';

/// null이면 통과, 문자열이면 틀린 이유
typedef PinCheck = Future<String?> Function(List<int> pin);

/// PIN 화면 한 벌: 입력 4칸 + 섞인 숫자패드.
/// 틀리면 입력을 지우고 숫자를 다시 섞는 것까지 여기서 한다. 화면은 check만 넘긴다.
class PinPage extends StatefulWidget {
  const PinPage({
    super.key,
    required this.title,
    required this.message,
    required this.check,
    this.titleSize = 18,
    this.back = true,
    this.footer,
  });

  final String title;
  final String message;
  final PinCheck check;
  final double? titleSize;
  final bool back;
  final Widget? footer;

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final _pin = <int>[];
  final _keys = List.generate(10, (i) => i)..shuffle();
  String? _error;

  Future<void> _press(int? n) async {
    if (n != null && _pin.length == 4) return; // 확인 중에는 더 받지 않는다
    setState(() {
      if (n == null) {
        if (_pin.isNotEmpty) _pin.removeLast();
      } else {
        _pin.add(n);
      }
    });
    if (_pin.length < 4) return;
    final err = await widget.check(List.of(_pin));
    if (!mounted) return;
    setState(() {
      _error = err ?? _error;
      _pin.clear();
      if (err != null) _keys.shuffle(); // 틀리면 숫자 배열도 바꾼다
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: TitleAppBar(
        title: widget.title,
        back: widget.back,
        center: true,
        titleSize: widget.titleSize,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: Padding(
        padding: const EdgeInsets.all(Gap.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Gap.l,
          children: [
            _Slots(_pin),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.xl),
              child: AppText.bold(
                14,
                _error == null ? AppColor.white : AppColor.red,
              ).text(_error ?? widget.message, align: TextAlign.center),
            ),
            const SizedBox(height: Gap.xl),
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                mainAxisExtent: 68,
              ),
              shrinkWrap: true,
              children: [
                for (final n in _keys.take(9)) _Key.digit(n, () => _press(n)),
                _Key(
                  'shuffle',
                  () => setState(_keys.shuffle),
                  AppText.medium(16, AppColor.whiteL1).text('재배열'),
                ),
                _Key.digit(_keys.last, () => _press(_keys.last)),
                _Key(
                  'back',
                  () => _press(null),
                  const Icon(Icons.arrow_back, color: AppColor.white),
                ),
              ],
            ),
            if (widget.footer case final f?) ...[
              const SizedBox(height: Gap.xxl),
              f,
            ],
          ],
        ),
      ),
    ),
  );
}

class _Slots extends StatelessWidget {
  const _Slots(this.pin);

  final List<int> pin;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      for (var i = 0; i < 4; i++)
        Container(
          key: Key('pin_slot_$i'),
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColor.white, width: 2)),
          ),
          // 방금 누른 숫자만 보여주고 나머지는 *
          child: i < pin.length
              ? AppText.bold(24).text(i == pin.length - 1 ? '${pin[i]}' : '*')
              : null,
        ),
    ],
  );
}

class _Key extends StatelessWidget {
  const _Key(this.name, this.onTap, this.child);

  _Key.digit(int n, this.onTap)
    : name = '$n',
      child = AppText.bold(24).text('$n');

  final String name;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    key: Key('pin_key_$name'),
    color: AppColor.blackL2,
    child: InkWell(
      onTap: onTap,
      child: Center(child: child),
    ),
  );
}
