/// 화면이 보여줄 수 있는 네 가지. sealed라서 하나를 빠뜨리면 컴파일이 안 된다.
sealed class UiState<T> {
  const UiState();
}

final class Loading<T> extends UiState<T> {
  const Loading();
}

final class Empty<T> extends UiState<T> {
  const Empty();
}

final class Failure<T> extends UiState<T> {
  const Failure(this.message);
  final String message;
}

final class Data<T> extends UiState<T> {
  const Data(this.value);
  final T value;
}
