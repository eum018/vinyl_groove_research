import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api_client.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/chip_group.dart';
import '../../core/widgets/form_section.dart';
import '../../core/widgets/submit_button.dart';
import '../../core/widgets/title_app_bar.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';

class RegiScreen extends StatefulWidget {
  const RegiScreen({super.key});

  @override
  State<RegiScreen> createState() => _RegiScreenState();
}

class _RegiScreenState extends State<RegiScreen> {
  final _name = TextEditingController();
  final _artist = TextEditingController();
  final _price = TextEditingController();
  final _barcode = TextEditingController();
  final _description = TextEditingController();

  Uint8List? _bytes; // 미리보기
  String? _imageUrl; // 서버에 올라간 주소
  Genre? _genre = Genre.rock;
  Condition? _condition = Condition.ss;
  Trade? _trade = Trade.direct;
  Map<String, String> _errors = const {}; // 서버가 준 칸별 에러
  static const _shownFields = {
    'albumImage',
    'albumName',
    'artist',
    'genre',
    'condition',
    'price',
    'tradeMethod',
  };

  Future<void> _pickImage(ImageSource source) async {
    // 사진을 줄여서 올린다 — 원래 크기 그대로 base64로 보내면 메모리와 전송량이 크다
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    final bytes = await file?.readAsBytes();
    if (!mounted) return;
    setState(() => _bytes = bytes); // 취소하면 미리보기도 지운다
    if (file == null || bytes == null) return;

    final res = await context.deps.products.uploadImage(bytes, file.mimeType);
    switch (res) {
      case Ok(:final value, :final message):
        _imageUrl = value;
        Native.toast(message);
      case Err(:final message):
        Native.toast(message);
    }
  }

  Future<void> _submit() async {
    final res = await context.deps.products.create(
      ProductDraft(
        albumName: _name.text,
        artist: _artist.text,
        genre: _genre,
        condition: _condition,
        price: int.tryParse(_price.text) ?? 0,
        trade: _trade,
        barcode: _barcode.text,
        description: _description.text,
        image: _imageUrl,
      ),
    );
    if (!mounted) return;
    switch (res) {
      case Ok(:final message):
        Native.toast(message);
        context.back(true);
      case Err(:final message, :final fields):
        setState(() => _errors = fields); // 서버가 준 에러를 전부 칸에 채운다
        if (!fields.keys.any(_shownFields.contains)) Native.toast(message);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _artist, _price, _barcode, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: const TitleAppBar(title: '상품 등록'),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Gap.l,
          children: [
            _Basics(this),
            _Choice(
              label: '장르 *',
              items: Genre.values,
              labelOf: (g) => g.label,
              value: _genre,
              onChanged: (g) => setState(() => _genre = g),
              error: _errors['genre'],
            ),
            _Choice(
              label: '음반 상태 *',
              items: Condition.values,
              labelOf: (c) => c.code,
              value: _condition,
              onChanged: (c) => setState(() => _condition = c),
              note: _condition?.description,
              error: _errors['condition'],
            ),
            _Text('가격 *', _price, '가격을 입력하세요', _errors['price']),
            _Choice(
              label: '거래 방식 *',
              items: Trade.values,
              labelOf: (t) => t.label,
              value: _trade,
              onChanged: (t) => setState(() => _trade = t),
              error: _errors['tradeMethod'],
            ),
            _Text('바코드 번호', _barcode, '바코드 번호 (선택)', null),
            _Text('상품 설명', _description, '상품에 대한 상세 설명을 입력하세요', null, lines: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.l),
              child: SubmitButton(
                key: const Key('regi_submit'),
                label: '등록하기',
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 사진·앨범명·아티스트
class _Basics extends StatelessWidget {
  const _Basics(this.s);

  final _RegiScreenState s;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.l,
    children: [
      _ImagePicker(
        bytes: s._bytes,
        error: s._errors['albumImage'],
        onPick: s._pickImage,
      ),
      _Text('앨범명 *', s._name, '앨범명을 입력하세요', s._errors['albumName']),
      _Text('아티스트 *', s._artist, '아티스트명을 입력하세요', s._errors['artist']),
    ],
  );
}

/// 사진 칸: 누르면 카메라/갤러리 메뉴
class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.bytes,
    required this.error,
    required this.onPick,
  });

  final Uint8List? bytes;
  final String? error;
  final ValueChanged<ImageSource> onPick;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.s,
    children: [
      PopupMenuButton<ImageSource>(
        key: const Key('regi_image'),
        color: AppColor.blackL2,
        onSelected: onPick,
        itemBuilder: (context) => [
          for (final (source, label) in [
            (ImageSource.camera, '카메라로 촬영'),
            (ImageSource.gallery, '갤러리에서 선택'),
          ])
            PopupMenuItem(
              value: source,
              child: AppText.regular(14, AppColor.whiteL1).text(label),
            ),
        ],
        child: _ImageBox(bytes),
      ),
      if (error case final e?) AppText.regular(14, AppColor.red).text(e),
    ],
  );
}

class _ImageBox extends StatelessWidget {
  const _ImageBox(this.bytes);

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) => Container(
    height: 200,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: AppColor.blackL2,
    ),
    foregroundDecoration: BoxDecoration(
      image: switch (bytes) {
        final b? => DecorationImage(image: MemoryImage(b)),
        null => null,
      },
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Gap.xs,
      children: [
        const Icon(
          Icons.add_photo_alternate_outlined,
          color: AppColor.whiteL3,
          size: 52,
        ),
        AppText.medium(14, AppColor.whiteL3).text('상품 이미지를 등록하세요'),
        AppText.regular(12, AppColor.whiteL3).text('터치하여 카메라/갤러리 선택'),
      ],
    ),
  );
}

/// 글자 입력 항목
class _Text extends StatelessWidget {
  const _Text(
    this.label,
    this.controller,
    this.hint,
    this.error, {
    this.lines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String? error;
  final int lines;

  @override
  Widget build(BuildContext context) => FormSection(
    label: label,
    bold: true,
    child: AppTextField(
      key: Key('regi_$label'),
      controller: controller,
      hint: hint,
      error: error,
      maxLines: lines,
    ),
  );
}

/// 하나만 고르는 칩 항목. 고른 칩을 다시 누르면 선택이 풀린다.
class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.items,
    required this.labelOf,
    required this.value,
    required this.onChanged,
    this.note,
    this.error,
  });

  final String label;
  final List<T> items;
  final String Function(T) labelOf;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? note;
  final String? error;

  @override
  Widget build(BuildContext context) => FormSection(
    label: label,
    bold: true,
    note: note,
    noteSize: 14,
    error: error,
    child: ChipGroup<T>(
      items: items,
      labelOf: labelOf,
      isSelected: (e) => e == value,
      onTap: (e) => onChanged(e == value ? null : e),
      wrap: true,
      fontSize: 14,
    ),
  );
}
