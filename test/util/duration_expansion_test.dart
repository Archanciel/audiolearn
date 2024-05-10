import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/utils/duration_expansion.dart';

void main() {
  group('DurationExpansion HHmmss (test not performed in DateTimeParser test)',
      () {
    test(
      'Duration 13 hours 35 minutes 23 seconds',
      () {
        const Duration duration = Duration(hours: 13, minutes: 35, seconds: 23);

        expect(duration.HHmmss(), '13:35:23');
      },
    );

    test(
      'Duration 3 hours 5 minutes 2 seconds',
      () {
        const Duration duration = Duration(hours: 3, minutes: 5, seconds: 2);

        expect(duration.HHmmss(), '3:05:02');
      },
    );

    test(
      'Duration 3 hours 5 minutes 0 seconds',
      () {
        const Duration duration = Duration(hours: 3, minutes: 5);

        expect(duration.HHmmss(), '3:05:00');
      },
    );

    test(
      'Duration -3 hours 5 minutes 2 seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(hours: 3, minutes: 5, seconds: 2));

        expect(duration.HHmmss(), '-3:05:02');
      },
    );

    test(
      'Duration 0 hours 5 minutes 0 seconds',
      () {
        const Duration duration = Duration(minutes: 5);

        expect(duration.HHmmss(), '0:05:00');
      },
    );

    test(
      'Duration -0 hours 5 minutes 2 seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(minutes: 5, seconds: 2));

        expect(duration.HHmmss(), '-0:05:02');
      },
    );

    test(
      'Duration -0 hours 0 minutes 2 seconds',
      () {
        final Duration duration =
            const Duration(milliseconds: 0) - (const Duration(seconds: 2));

        expect(duration.HHmmss(), '-0:00:02');
      },
    );
  });

  group(
      'DurationExpansion HHmmssZeroHH (test not performed in DateTimeParser test)',
      () {
    test(
      'Duration 13 hours 35 minutes 23 seconds',
      () {
        const Duration duration = Duration(hours: 13, minutes: 35, seconds: 23);

        expect(duration.HHmmssZeroHH(), '13:35:23');
      },
    );

    test(
      'Duration -13 hours 35 minutes 23 seconds',
      () {
        final Duration duration = const Duration(microseconds: 0) -
            const Duration(hours: 13, minutes: 35, seconds: 23);

        expect(duration.HHmmssZeroHH(), '-13:35:23');
      },
    );

    test(
      'Duration 3 hours 5 minutes 2 seconds',
      () {
        const Duration duration = Duration(hours: 3, minutes: 5, seconds: 2);

        expect(duration.HHmmssZeroHH(), '3:05:02');
      },
    );

    test(
      'Duration 3 hours 5 minutes 0 seconds',
      () {
        const Duration duration = Duration(hours: 3, minutes: 5);

        expect(duration.HHmmssZeroHH(), '3:05:00');
      },
    );

    test(
      'Duration -3 hours 5 minutes 2 seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(hours: 3, minutes: 5, seconds: 2));

        expect(duration.HHmmssZeroHH(), '-3:05:02');
      },
    );

    test(
      'Duration 0 hours 15 minutes 0 seconds',
      () {
        const Duration duration = Duration(minutes: 15);

        expect(duration.HHmmssZeroHH(), '15:00');
      },
    );

    test(
      'Duration 0 hours 5 minutes 0 seconds',
      () {
        const Duration duration = Duration(minutes: 5);

        expect(duration.HHmmssZeroHH(), '5:00');
      },
    );

    test(
      'Duration 0 hours 15 minutes 0 seconds',
      () {
        const Duration duration = Duration(minutes: 15);

        expect(duration.HHmmssZeroHH(), '15:00');
      },
    );

    test(
      'Duration -0 hours 5 minutes 2 seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(minutes: 5, seconds: 2));

        expect(duration.HHmmssZeroHH(), '-5:02');
      },
    );

    test(
      'Duration 0 hours 0 minutes 2 seconds',
      () {
        const Duration duration = Duration(seconds: 2);

        expect(duration.HHmmssZeroHH(), '0:02');
      },
    );

    test(
      'Duration 0 hours 0 minutes 0 seconds',
      () {
        const Duration duration = Duration(seconds: 0);

        expect(duration.HHmmssZeroHH(), '0:00');
      },
    );

    test(
      'Duration -0 hours 0 minutes 2 seconds',
      () {
        final Duration duration =
            const Duration(milliseconds: 0) - (const Duration(seconds: 2));

        expect(duration.HHmmssZeroHH(), '-0:02');
      },
    );
  });
  group(
      'DurationExpansion HHmmssZeroHH ensuring durations are correctly rounded (test not performed in DateTimeParser test)',
      () {
    test(
      'Duration 0 hours 0 minutes 2000 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 2000);

        expect(duration.HHmmssZeroHH(), '0:02');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2499 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 2499);

        expect(duration.HHmmssZeroHH(), '0:02');
      },
    );
    test(
      'Duration 0 hours 0 minutes -2499 milliseconds',
      () {
        Duration duration =
            const Duration() - const Duration(milliseconds: 2499);

        expect(duration.HHmmssZeroHH(), '-0:02');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2500 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 2500);

        expect(duration.HHmmssZeroHH(), '0:03');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2501 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 2501);

        expect(duration.HHmmssZeroHH(), '0:03');
      },
    );

    test(
      'Duration 0 hours 0 minutes 59000 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 59000);

        expect(duration.HHmmssZeroHH(), '0:59');
      },
    );
    test(
      'Duration 0 hours 0 minutes 58499 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 58499);

        expect(duration.HHmmssZeroHH(), '0:58');
      },
    );
    test(
      'Duration 0 hours 0 minutes 58500 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 58500);

        expect(duration.HHmmssZeroHH(), '0:59');
      },
    );
    test(
      'Duration 0 hours 0 minutes 58501 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 58501);

        expect(duration.HHmmssZeroHH(), '0:59');
      },
    );

    test(
      'Duration 0 hours 2 minutes 2000 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 122000);

        expect(duration.HHmmssZeroHH(), '2:02');
      },
    );
    test(
      'Duration 0 hours 2 minutes 2499 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 122499);

        expect(duration.HHmmssZeroHH(), '2:02');
      },
    );
    test(
      'Duration 0 hours 2 minutes 2500 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 122500);

        expect(duration.HHmmssZeroHH(), '2:03');
      },
    );
    test(
      'Duration 0 hours -2 minutes 2500 milliseconds',
      () {
        Duration duration =
            const Duration() - const Duration(milliseconds: 122500);

        expect(duration.HHmmssZeroHH(), '-2:03');
      },
    );
    test(
      'Duration 0 hours 2 minutes 2501 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 122501);

        expect(duration.HHmmssZeroHH(), '2:03');
      },
    );

    test(
      'Duration 0 hours 10 minutes 59000 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 659000);

        expect(duration.HHmmssZeroHH(), '10:59');
      },
    );
    test(
      'Duration 0 hours 10 minutes 58499 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 658499);

        expect(duration.HHmmssZeroHH(), '10:58');
      },
    );
    test(
      'Duration 0 hours 10 minutes 58500 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 658500);

        expect(duration.HHmmssZeroHH(), '10:59');
      },
    );
    test(
      'Duration 0 hours 10 minutes 58501 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 658501);

        expect(duration.HHmmssZeroHH(), '10:59');
      },
    );
    test(
      'Duration 0 hours -10 minutes 58501 milliseconds',
      () {
        Duration duration =
            const Duration() - const Duration(milliseconds: 658501);

        expect(duration.HHmmssZeroHH(), '-10:59');
      },
    );

    test(
      'Duration 2 hours 10 minutes 59000 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 7859000);

        expect(duration.HHmmssZeroHH(), '2:10:59');
      },
    );
    test(
      'Duration 2 hours 10 minutes 58499 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 7858499);

        expect(duration.HHmmssZeroHH(), '2:10:58');
      },
    );
    test(
      'Duration 2 hours 10 minutes 58500 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 7858500);

        expect(duration.HHmmssZeroHH(), '2:10:59');
      },
    );
    test(
      'Duration -2 hours 10 minutes 58500 milliseconds',
      () {
        Duration duration =
            const Duration() - const Duration(milliseconds: 7858500);

        expect(duration.HHmmssZeroHH(), '-2:10:59');
      },
    );
    test(
      'Duration 2 hours 10 minutes 58501 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 7858501);

        expect(duration.HHmmssZeroHH(), '2:10:59');
      },
    );
  });
}
