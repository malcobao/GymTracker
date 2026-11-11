/// The four states every screen can be in.
sealed class ViewState<T> {
  const ViewState();
}

final class Loading<T> extends ViewState<T> {
  const Loading();
}

final class Loaded<T> extends ViewState<T> {
  const Loaded(this.data);
  final T data;
}

/// Loaded successfully, but there is nothing to show yet.
final class Empty<T> extends ViewState<T> {
  const Empty();
}

/// Loading failed; the screen shows a translated message for [error].
final class Failed<T> extends ViewState<T> {
  const Failed(this.error);
  final Exception error;
}
