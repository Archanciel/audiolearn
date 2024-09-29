import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/utils/duration_expansion.dart';

void main() {
  group('DurationExpansion HHmmss', () {
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
  group('DurationExpansion HHmmss.tenthSec', () {
    test(
      'Duration 13 hours 35 minutes 23 seconds 2 tenth of seconds',
      () {
        const Duration duration =
            Duration(hours: 13, minutes: 35, seconds: 23, milliseconds: 200);

        expect(duration.HHmmss(addRemainingOneDigitTenthOfSecond: true),
            '13:35:23.2');
      },
    );

    test(
      'Duration 3 hours 5 minutes 2 seconds 5 tenth of seconds',
      () {
        const Duration duration =
            Duration(hours: 3, minutes: 5, seconds: 2, milliseconds: 500);

        expect(duration.HHmmss(addRemainingOneDigitTenthOfSecond: true),
            '3:05:02.5');
      },
    );

    test(
      'Duration 3 hours 5 minutes 0 seconds 3 tenth of seconds',
      () {
        const Duration duration =
            Duration(hours: 3, minutes: 5, milliseconds: 300);

        expect(duration.HHmmss(addRemainingOneDigitTenthOfSecond: true),
            '3:05:00.3');
      },
    );

    test(
      'Duration -3 hours 5 minutes 2 seconds 1 tenth of seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(
                hours: 3, minutes: 5, seconds: 2, milliseconds: 100));

        expect(duration.HHmmss(addRemainingOneDigitTenthOfSecond: true),
            '-3:05:02.1');
      },
    );

    test(
      'Duration 0 hours 5 minutes 0 seconds 2 tenth of seconds',
      () {
        const Duration duration = Duration(minutes: 5, milliseconds: 200);

        expect(duration.HHmmss(addRemainingOneDigitTenthOfSecond: true),
            '0:05:00.2');
      },
    );

    test(
      'Duration -0 hours 5 minutes 2 seconds 8 tenth of seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(minutes: 5, seconds: 2, milliseconds: 800));

        expect(duration.HHmmss(addRemainingOneDigitTenthOfSecond: true),
            '-0:05:02.8');
      },
    );

    test(
      'Duration -0 hours 0 minutes 2 seconds 9 tenth of seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(seconds: 2, milliseconds: 900));

        expect(duration.HHmmss(addRemainingOneDigitTenthOfSecond: true),
            '-0:00:02.9');
      },
    );
  });

  group('DurationExpansion HHmmssZeroHH', () {
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
      'Duration 0 hours 5 minutes 2 seconds',
      () {
        const Duration duration = Duration(minutes: 5, seconds: 2);

        expect(duration.HHmmssZeroHH(), '5:02');
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
    test(
      'Duration 0 hours 0 minutes 52.5 seconds',
      () {
        const Duration duration = (Duration(milliseconds: 52500));

        expect(duration.HHmmssZeroHH(), '0:53');
        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:52.5');
      },
    );
  });
  group('DurationExpansion HHmmssZeroHH.tenthSec', () {
    test(
      'Duration 13 hours 35 minutes 23 seconds 1 tenth of seconds',
      () {
        const Duration duration =
            Duration(hours: 13, minutes: 35, seconds: 23, milliseconds: 100);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '13:35:23.1');
      },
    );
    test(
      'Duration 13 hours 35 minutes 23 seconds 9 tenth of seconds',
      () {
        const Duration duration =
            Duration(hours: 13, minutes: 35, seconds: 23, milliseconds: 900);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '13:35:23.9');
      },
    );

    test(
      'Duration -13 hours 35 minutes 23 seconds 9 tenth of seconds',
      () {
        final Duration duration = const Duration(microseconds: 0) -
            const Duration(
                hours: 13, minutes: 35, seconds: 23, milliseconds: 900);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-13:35:23.9');
      },
    );

    test(
      'Duration -13 hours 35 minutes 23 seconds 1 tenth of seconds',
      () {
        final Duration duration = const Duration(microseconds: 0) -
            const Duration(
                hours: 13, minutes: 35, seconds: 23, milliseconds: 100);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-13:35:23.1');
      },
    );

    test(
      'Duration 3 hours 5 minutes 2 seconds 7 tenth of seconds',
      () {
        const Duration duration =
            Duration(hours: 3, minutes: 5, seconds: 2, milliseconds: 700);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '3:05:02.7');
      },
    );

    test(
      'Duration 3 hours 5 minutes 0 seconds 9 tenth of seconds',
      () {
        const Duration duration =
            Duration(hours: 3, minutes: 5, milliseconds: 900);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '3:05:00.9');
      },
    );

    test(
      'Duration -3 hours 5 minutes 2 seconds 5 tenth of seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(
                hours: 3, minutes: 5, seconds: 2, milliseconds: 500));

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-3:05:02.5');
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
      'Duration 0 hours 5 minutes 0 seconds 2 tenth of seconds',
      () {
        const Duration duration = Duration(minutes: 5, milliseconds: 200);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '5:00.2');
      },
    );

    test(
      'Duration 0 hours 15 minutes 0 seconds 9 tenth of seconds',
      () {
        const Duration duration = Duration(minutes: 15, milliseconds: 900);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '15:00.9');
      },
    );

    test(
      'Duration -0 hours 5 minutes 2 seconds 3 tenth of seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(minutes: 5, seconds: 2, milliseconds: 300));

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-5:02.3');
      },
    );

    test(
      'Duration 0 hours 0 minutes 2 seconds 9 tenth of seconds',
      () {
        const Duration duration = Duration(seconds: 2, milliseconds: 900);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:02.9');
      },
    );

    test(
      'Duration 0 hours 0 minutes 0 seconds 1 tenth of seconds',
      () {
        const Duration duration = Duration(milliseconds: 100);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:00.1');
      },
    );

    test(
      'Duration -0 hours 0 minutes 2 seconds 1 tenth of seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(seconds: 2, milliseconds: 100));

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-0:02.1');
      },
    );
  });
  group(
      'DurationExpansion HHmmssZeroHH ensuring durations are correctly rounded',
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
        Duration duration = Duration.zero - const Duration(milliseconds: 2499);

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
      'Duration 0 hours 0 minutes 2999 milliseconds',
      () {
        const Duration duration = Duration(milliseconds: 2999);

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
            Duration.zero - const Duration(milliseconds: 122500);

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
            Duration.zero - const Duration(milliseconds: 658501);

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
            Duration.zero - const Duration(milliseconds: 7858500);

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
  group(
      'DurationExpansion HHmmssZeroHH.tenthSec ensuring durations are correctly rounded',
      () {
    test(
      'Duration 0 hours 0 minutes 2000 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 2000);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:02.0');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2499 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 2499);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:02.5');
      },
    );
    test(
      'Duration 0 hours 0 minutes -2499 milliseconds with tenth of second remaining',
      () {
        Duration duration = Duration.zero - const Duration(milliseconds: 2499);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-0:02.5');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2500 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 2500);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:02.5');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2501 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 2501);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:02.5');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2999 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 2999);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:03.0');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2900 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 2900);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:02.9');
      },
    );
    test(
      'Duration 0 hours 0 minutes 2950 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 2950);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:03.0');
      },
    );
    test(
      'Duration 0 hours 0 minutes 59000 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 59000);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:59.0');
      },
    );
    test(
      'Duration 0 hours 0 minutes 58499 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 58499);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:58.5');
      },
    );
    test(
      'Duration 0 hours 0 minutes 58500 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 58500);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:58.5');
      },
    );
    test(
      'Duration 0 hours 0 minutes 58501 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 58501);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:58.5');
      },
    );

    test(
      'Duration 0 hours 2 minutes 2000 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 122000);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '2:02.0');
      },
    );
    test(
      'Duration 0 hours 2 minutes 2499 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 122499);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '2:02.5');
      },
    );
    test(
      'Duration 0 hours 2 minutes 2500 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 122500);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '2:02.5');
      },
    );
    test(
      'Duration 0 hours -2 minutes 2500 milliseconds with tenth of second remaining',
      () {
        Duration duration =
            Duration.zero - const Duration(milliseconds: 122500);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-2:02.5');
      },
    );
    test(
      'Duration 0 hours 2 minutes 2501 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 122501);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '2:02.5');
      },
    );
    test(
      'Duration 0 hours 10 minutes 59000 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 659000);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '10:59.0');
      },
    );
    test(
      'Duration 0 hours 10 minutes 58499 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 658499);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '10:58.5');
      },
    );
    test(
      'Duration 0 hours 10 minutes 58500 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 658500);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '10:58.5');
      },
    );
    test(
      'Duration 0 hours 10 minutes 58501 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 658501);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '10:58.5');
      },
    );
    test(
      'Duration 0 hours -10 minutes 58501 milliseconds with tenth of second remaining',
      () {
        Duration duration =
            Duration.zero - const Duration(milliseconds: 658501);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-10:58.5');
      },
    );

    test(
      'Duration 2 hours 10 minutes 59000 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 7859000);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '2:10:59.0');
      },
    );
    test(
      'Duration 2 hours 10 minutes 58499 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 7858499);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '2:10:58.5');
      },
    );
    test(
      'Duration 2 hours 10 minutes 58500 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 7858500);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '2:10:58.5');
      },
    );
    test(
      'Duration -2 hours 10 minutes 58500 milliseconds with tenth of second remaining',
      () {
        Duration duration =
            Duration.zero - const Duration(milliseconds: 7858500);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '-2:10:58.5');
      },
    );
    test(
      'Duration 2 hours 10 minutes 58501 milliseconds with tenth of second remaining',
      () {
        const Duration duration = Duration(milliseconds: 7858501);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '2:10:58.5');
      },
    );
    test(
      'Duration 0 hours 0 minutes 52.5 seconds',
      () {
        const Duration duration = (Duration(milliseconds: 52500));

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true),
            '0:52.5');
        expect(duration.HHmmssZeroHH(), '0:53');
      },
    );
  });
  group(
      'DurationExpansion HHmmssZeroHH oh Duration containing tenth of seconds ensuring durations are correctly rounded',
      () {
    test(
      'Duration 0:52.4',
      () {
        const Duration duration = Duration(seconds: 52, milliseconds: 400);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: false),
            '0:52');
      },
    );
    test(
      'Duration 0:52.5',
      () {
        const Duration duration = Duration(seconds: 52, milliseconds: 500);

        expect(duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: false),
            '0:53');
      },
    );
  });
}
