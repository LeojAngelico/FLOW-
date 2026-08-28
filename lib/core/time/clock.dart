/// Injectable source of "now". Nothing outside this file may call
/// `DateTime.now()` directly — everything else reads through a [Clock]
/// so tests can control time and the dev flavor can override it.
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// A [Clock] whose instant is fixed until [set] is called again.
/// Used by tests and by the dev-flavor debug clock override.
class FixedClock implements Clock {
  FixedClock(this._current);

  DateTime _current;

  @override
  DateTime now() => _current;

  void set(DateTime value) {
    _current = value;
  }
}
