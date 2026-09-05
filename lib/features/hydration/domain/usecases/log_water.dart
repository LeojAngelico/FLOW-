import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/time/local_date.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../models/hydration_entry.dart';
import '../models/logged_water.dart';
import '../repositories/hydration_repository.dart';

/// Logs one water-intake entry. **The only place an entry is created**
/// — quick-add chips and the custom-amount screen both call this with a
/// different [HydrationSource], never the repository directly.
///
/// Owns everything that has to happen before the write reaches storage:
/// - validating the 50–2,000 ml bound (`FR-024`) into a
///   `ValidationFailure`, so a bypassed UI still can't write an invalid
///   entry;
/// - generating the entry's id;
/// - reading "now" from the injected [Clock] rather than
///   `DateTime.now()`, so tests can control time and the dev flavor can
///   override it;
/// - deriving `localDate` from that instant (`BR-15`/`BR-16`).
class LogWater {
  LogWater(this._repository, this._clock);

  final HydrationRepository _repository;
  final Clock _clock;

  /// `FR-024` lower bound. Public so the custom-amount screen's stepper
  /// clamps to the same number instead of duplicating the magic value.
  static const minAmountMl = 50;

  /// `FR-024` upper bound. Public for the same reason as [minAmountMl].
  static const maxAmountMl = 2000;

  Future<Result<LoggedWater>> call({
    required int amountMl,
    required HydrationSource source,
  }) async {
    if (amountMl < minAmountMl || amountMl > maxAmountMl) {
      return Result.err(
        ValidationFailure(
          'amountMl',
          'Enter an amount between $minAmountMl and $maxAmountMl ml.',
        ),
      );
    }

    final occurredAt = _clock.now();
    final localDate = localDateFromDateTime(occurredAt);

    return _repository.logWater(
      id: newUuidV4(),
      amountMl: amountMl,
      occurredAt: occurredAt,
      localDate: localDate,
      source: source,
    );
  }
}
