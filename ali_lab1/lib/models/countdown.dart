import 'package:flutter/foundation.dart';

@immutable
sealed class Countdown {
  const Countdown();
}

class UpcomingCountdown extends Countdown {
  final Duration remaining;
  const UpcomingCountdown(this.remaining);
}

class StartedCountdown extends Countdown {
  final Duration elapsed;
  const StartedCountdown(this.elapsed);
}

class EndedCountdown extends Countdown {
  const EndedCountdown();
}
