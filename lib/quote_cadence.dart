/// Focus-style quote schedule: every two minutes through 15:00, then 16:30,
/// then every two minutes on the :30.
const announceEvery = Duration(seconds: 60);
const denseUntil = Duration(minutes: 15);
const afterDenseFirstGap = Duration(seconds: 90);
const afterDenseEvery = Duration(minutes: 2);
const quoteEvery = Duration(minutes: 2);

/// Latest announcement boundary that has already fallen due.
Duration latestDue(Duration elapsed) {
  if (elapsed < announceEvery) return Duration.zero;
  if (elapsed < denseUntil + afterDenseFirstGap) {
    final mins = elapsed.inSeconds ~/ announceEvery.inSeconds;
    final cap = denseUntil.inSeconds ~/ 60;
    return Duration(seconds: (mins < cap ? mins : cap) * 60);
  }
  final first = denseUntil + afterDenseFirstGap;
  final steps = (elapsed - first).inSeconds ~/ afterDenseEvery.inSeconds;
  return first + (afterDenseEvery * steps);
}

bool quoteWith(Duration at) {
  return at >= denseUntil || at.inSeconds % quoteEvery.inSeconds == 0;
}

/// Consumes each [latestDue] once so quotes fire on the Focus schedule
/// without changing whole-minute announcements.
class QuoteCadence {
  Duration _lastDue = Duration.zero;

  bool takePending(Duration elapsed) {
    final due = latestDue(elapsed);
    if (due <= _lastDue) return false;
    _lastDue = due;
    return quoteWith(due);
  }
}
