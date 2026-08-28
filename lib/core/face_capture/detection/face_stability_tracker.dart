/// Tracks how long the capture conditions have held.
///
/// A single good frame is not a good photo: detection flickers, heads
/// drift, and a smile can be misread for one frame. So capture waits
/// for the conditions to survive a short window, and this is the thing
/// that measures it.
///
/// Failures **decay** the accumulated time rather than zeroing it,
/// at [decayFactor]× the elapsed time. One dropped frame therefore
/// costs a little progress instead of restarting the whole hold, while
/// genuinely losing the face still empties it quickly.
///
/// Time is injected rather than read from the clock, so the behaviour
/// is deterministic and unit testable.
class FaceStabilityTracker {
  /// How long the conditions must hold in total.
  final Duration holdDuration;

  /// How fast accumulated time is given back when a frame fails.
  final double decayFactor;

  FaceStabilityTracker({required this.holdDuration, this.decayFactor = 2.5})
    : assert(holdDuration > Duration.zero, 'holdDuration must be positive.');

  Duration _held = Duration.zero;
  DateTime? _lastUpdate;

  /// Progress through the hold period, 0..1.
  double get progress {
    return (_held.inMicroseconds / holdDuration.inMicroseconds).clamp(0.0, 1.0);
  }

  /// Whether the hold is complete.
  bool get isStable => progress >= 1;

  /// Feeds one frame in and returns the new [progress].
  ///
  /// [now] is the frame's timestamp. The first call only establishes a
  /// baseline — no elapsed time exists yet — so it always returns 0.
  double update({required bool conditionsMet, required DateTime now}) {
    final last = _lastUpdate;
    _lastUpdate = now;

    if (last == null) {
      return progress;
    }

    var elapsed = now.difference(last);

    if (elapsed.isNegative) {
      elapsed = Duration.zero;
    }

    if (conditionsMet) {
      _held += elapsed;

      if (_held > holdDuration) {
        _held = holdDuration;
      }
    } else {
      _held -= elapsed * decayFactor;

      if (_held.isNegative) {
        _held = Duration.zero;
      }
    }

    return progress;
  }

  /// Drops all accumulated time and the timing baseline.
  ///
  /// Used when the camera restarts or flips, where elapsed wall-clock
  /// time says nothing about how steady the user was.
  void reset() {
    _held = Duration.zero;
    _lastUpdate = null;
  }
}
