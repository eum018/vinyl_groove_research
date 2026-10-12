import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/app_icon.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/submit_button.dart';

/// 카메라로 바코드를 읽거나 직접 입력한다. 읽은 번호를 돌려주며 닫힌다.
class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final _manual = TextEditingController();
  CameraController? _camera;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final back = context.deps.cameras
        .where((c) => c.lensDirection == CameraLensDirection.back)
        .firstOrNull;
    if (back == null) return _fail(); // 카메라가 없는 기기
    final camera = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await camera.initialize();
    } catch (_) {
      await camera.dispose();
      return _fail(); // 권한 거부 등
    }
    if (!mounted) return camera.dispose();
    setState(() => _camera = camera);
    await camera.startImageStream(_onFrame);
  }

  void _fail() {
    Native.toast('카메라 권한이 필요합니다');
    if (mounted) context.back();
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_scanning) return;
    _scanning = true;
    // 세로 화면에 맞게 돌려서 넘긴다
    final code = await Native.scan(_rotate(image), image.height, image.width);
    if (code != null && mounted) {
      await _camera?.stopImageStream();
      if (mounted) context.back(code);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _scanning = false;
  }

  Future<void> _typeIn() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => _ManualDialog(_manual),
    );
    if (code != null && mounted) context.back(code);
  }

  @override
  void dispose() {
    _camera?.dispose();
    _manual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const Key('back'),
          onPressed: () => context.back(),
          icon: const Icon(Icons.close, color: AppColor.whiteL1, size: 32),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: AppText.bold(20).text('바코드 검색'),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Gap.l),
            child: AppText.bold(
              14,
              AppColor.whiteL1,
            ).text('상품의 바코드를 화면 중앙에 맞춰주세요'),
          ),
          Expanded(child: _Viewfinder(_camera)),
          Padding(
            padding: const EdgeInsets.all(Gap.l),
            child: TextButton(
              key: const Key('barcode_manual'),
              onPressed: _typeIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  AppIcon.barcode.icon(color: AppColor.whiteL1, size: Gap.xl),
                  AppText.medium(16, AppColor.whiteL1).text('직접 입력'),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.xl),
        ],
      ),
    ),
  );
}

/// 카메라 원본은 가로로 누워 있다. 90도 돌린 밝기(Y) 값만 넘긴다.
Uint8List _rotate(CameraImage image) {
  final src = image.planes[0].bytes;
  final (w, h) = (image.width, image.height);
  final out = Uint8List(w * h);
  var i = 0;
  for (var x = 0; x < w; x++) {
    for (var y = h - 1; y >= 0; y--) {
      out[i++] = src[y * w + x];
    }
  }
  return out;
}

/// 카메라 화면 + 가운데 창 + 움직이는 선 + 모서리
class _Viewfinder extends StatelessWidget {
  const _Viewfinder(this.camera);

  final CameraController? camera;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (camera case final c?) CameraPreview(c) else const SizedBox(),
        const _Mask(),
        const _ScanLine(),
        const _Corners(),
      ],
    ),
  );
}

const _window = Size(280, 160);

/// 가운데 창만 밝게, 나머지는 어둡게
class _Mask extends StatelessWidget {
  const _Mask();

  @override
  Widget build(BuildContext context) => ColorFiltered(
    colorFilter: const ColorFilter.mode(AppColor.dim, BlendMode.srcOut),
    child: Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Container(
        color: AppColor.black,
        width: _window.width,
        height: _window.height,
      ),
    ),
  );
}

/// 창 안에서 위아래로 오가는 선
class _ScanLine extends StatelessWidget {
  const _ScanLine();

  @override
  Widget build(BuildContext context) => Center(
    child: RepeatingAnimationBuilder(
      animatable: Tween<double>(begin: 0, end: 1),
      repeatMode: .reverse,
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, _) => SizedBox.fromSize(
        size: _window,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 1200),
          alignment: value <= .5 ? Alignment.topCenter : Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(Gap.s),
            child: Divider(
              color: AppColor.yellow.withAlpha(100),
              thickness: 1.5,
            ),
          ),
        ),
      ),
    ),
  );
}

/// 창 네 모서리의 ㄱ자 표시 (숨 쉬듯 커졌다 작아진다)
class _Corners extends StatelessWidget {
  const _Corners();

  @override
  Widget build(BuildContext context) => Center(
    child: RepeatingAnimationBuilder(
      animatable: Tween<double>(begin: 0, end: 1),
      repeatMode: .reverse,
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) => AnimatedScale(
        duration: const Duration(milliseconds: 1200),
        scale: value * .3 + .9,
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox.fromSize(
          size: _window,
          child: Stack(
            children: [
              for (final a in [
                Alignment.topLeft,
                Alignment.topRight,
                Alignment.bottomLeft,
                Alignment.bottomRight,
              ]) ...[
                Align(alignment: a, child: const _Bar(20, 3)),
                Align(alignment: a, child: const _Bar(3, 20)),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar(this.width, this.height);

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      Container(color: AppColor.yellow, width: width, height: height);
}

class _ManualDialog extends StatelessWidget {
  const _ManualDialog(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColor.blackL2,
    child: Padding(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Gap.xl,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.bold(24).text('바코드 직접 입력'),
          AppTextField(
            key: const Key('barcode_input'),
            controller: controller,
            hint: '바코드를 입력해주세요.',
            icon: AppIcon.barcode,
          ),
          Row(
            spacing: Gap.xl,
            children: [
              Expanded(
                child: SubmitButton(
                  key: const Key('barcode_search'),
                  label: '검색',
                  onPressed: () => context.back(controller.text),
                ),
              ),
              Expanded(
                child: SubmitButton(
                  label: '취소',
                  onPressed: () => context.back(),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
