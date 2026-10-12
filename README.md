# Vinyl Groove

중고 LP 거래 앱. 로그인·회원가입, 홈, 탐색(필터·검색), 상품 상세, 상품 등록, 관심상품, 알림, 바코드 검색, PIN 간편 로그인이 있다.

외부 상태관리·DI·라우팅 패키지 없이 **Flutter 기본 기능만** 쓴다 (`ChangeNotifier`, `InheritedWidget`, `Navigator.pushNamed`, Dart 3 `sealed class`).

## 돌려보기

```bash
flutter pub get
flutter analyze
flutter test        # 서버 없이 돈다
flutter run
```

- Dart `^3.10.0`
- 서버 주소는 `lib/core/api_client.dart`의 `ApiClient.host` 한 곳에만 있다

## 폴더

```
lib/
  main.dart             시작: 카메라 찾기(없어도 앱은 뜬다) → Deps.production() → runApp
  app.dart              화면 이름 → 화면 연결표. 화면끼리는 서로를 import하지 않는다
  core/                 앱 내용을 모르는 부분 — 다른 앱에도 그대로 쓸 수 있다
    theme.dart          색·간격·글자·입력창·버튼 모양
    app_icon.dart       아이콘
    api_client.dart     Result(Ok/Err) + ApiClient: 주소·타임아웃·에러 처리
    ui_state.dart       Loading · Empty · Failure · Data
    list_controller.dart 목록 한 벌: 페이지·늦게 온 응답 버리기·디바운스
    scope.dart          Deps(Repository·Store 묶음) + AppScope
    nav.dart            화면 이름(Routes) + go/re/reset/back
    native.dart         안드로이드 채널(토스트·바코드 해석)
    format.dart         ₩ 표시, "n분 전"
    widgets/            공용 위젯, 파일 하나에 하나
  domain/
    enums.dart          음반 상태 · 장르 · 정렬 · 거래 방식
    validators.dart     입력 검증 규칙과 문구
    search_filter.dart  탐색 필터
    models.dart         서버 JSON → 모델. 값이 이상해도 예외를 던지지 않는다
  data/
    *_repository.dart   abstract class + Http 구현
    fake_repositories.dart  서버 없이 띄울 때 쓰는 가짜
    stores/             Session · Like · Alert · Pin · Search
  presentation/         화면 (기능별 폴더) + 앱 전용 공용 위젯
test/
```

## 코드를 나눈 기준

**한 가지 일은 한 곳에서.** 서버 주소·타임아웃·에러 처리는 `api_client.dart`, 검증 규칙과 문구는 `validators.dart`, 정해진 값은 `enums.dart`에만 있다. 고칠 일이 생기면 그 파일 하나만 고친다.

**빠뜨린 경우는 컴파일러가 잡는다.** 통신 결과는 `Result`(`Ok`/`Err`), 화면 상태는 `UiState`(`Loading`/`Empty`/`Failure`/`Data`)로, 둘 다 `sealed class`다. `switch`에서 하나를 빠뜨리면 빌드가 안 된다.

**화면은 서버를 모른다.** 화면은 Repository에 "무엇을" 원하는지만 말한다 (`repo.search(filter, page)`). Repository는 `abstract class`라서 테스트에서는 가짜로 바꿔 끼운다 (`Deps.fake()`).

**데이터는 Store가 갖고, 바꾸는 방법은 Store의 메서드뿐이다.** 화면은 `context.deps.likes.toggle(album)`처럼 부르기만 한다. 로그아웃 때 비울 것은 `Deps.logout()` 한 곳에 모여 있다.

**목록 화면은 `ListController` 한 벌을 쓴다.** 로딩·빈 목록·실패("다시 시도")·데이터를 같은 방식으로 그린다. 페이지는 성공했을 때만 올리고, 늦게 도착한 옛 응답은 버린다.

**`build()`는 짧고 얕게.** 큰 덩어리는 메서드가 아니라 위젯 클래스로 뺀다.

## 테스트

`test/` — 서버 없이 가짜 Repository로 돈다.

- 탐색 화면이 뜨고, 실패하면 "다시 시도"가 보인다
- PIN을 틀리면 입력 칸이 비워진다
- 로그아웃하면 Store가 전부 비워진다
- 늦게 온 응답은 버리고, 페이지는 성공했을 때만 올라간다
- 입력 검증 규칙과 문구
