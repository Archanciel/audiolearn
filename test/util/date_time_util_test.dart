import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/utils/date_time_util.dart';

void main() {
  group(
    'DateTimeUtil.convertToTenthsOfSeconds()',
    () {
      test(
        '0 hh, 0 mm, 0 ss no tenth of second',
        () {
          const String timeStr = '0:0:0';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 0);
        },
      );
      test(
        '0 mm, 0 ss no tenth of second',
        () {
          const String timeStr = '0:0';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 0);
        },
      );
      test(
        '0 hh, 0 mm, 0 ss 0 tenth of second',
        () {
          const String timeStr = '0:0:0.0';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 0);
        },
      );
      test(
        '0 mm, 0 ss 0 tenth of second',
        () {
          const String timeStr = '0:0.0';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 0);
        },
      );
      test(
        'negative 0 hh, 0 mm, 0 ss no tenth of second',
        () {
          const String timeStr = '-0:0:0';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 0);
        },
      );
      test(
        'negative 0 mm, 0 ss no tenth of second',
        () {
          const String timeStr = '-0:0';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 0);
        },
      );
      test(
        'negative 0 hh, 0 mm, 0 ss 0 tenth of second',
        () {
          const String timeStr = '-0:0:0.0';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 0);
        },
      );
      test(
        'negative 0 mm, 0 ss 0 tenth of second',
        () {
          const String timeStr = '-0:0.0';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 0);
        },
      );
      test(
        '0 hh, 0 mm, 0 ss 1 tenth of second',
        () {
          const String timeStr = '0:0:0.1';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 1);
        },
      );
      test(
        '0 hh, 0 mm, 40 ss no tenth of second',
        () {
          String timeStr = '0:0:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 400);
        },
      );
      test(
        '0 hh, 0 mm, 40 ss 3 tenth of second',
        () {
          String timeStr = '0:0:40.3';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 403);
        },
      );
      test(
        '0 hh, 5 mm, 40 ss 0 tenth of second',
        () {
          String timeStr = '0:5:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          int expectedTenthOfSeconds = 3400;
          expect(totalTenthsOfSeconds, expectedTenthOfSeconds);
        },
      );
      test(
        '0 hh, 5 mm, 40 ss 9 tenth of second',
        () {
          String timeStr = '0:5:40.9';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          int expectedTenthOfSeconds = 3409;
          expect(totalTenthsOfSeconds, expectedTenthOfSeconds);
        },
      );
      test(
        '0 mm, 0 ss 1 tenth of second',
        () {
          const String timeStr = '0:0.1';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 1);
        },
      );
      test(
        '0 mm, 40 ss no tenth of second',
        () {
          String timeStr = '0:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 400);
        },
      );
      test(
        '0 mm, 40 ss 3 tenth of second',
        () {
          String timeStr = '0:40.3';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 403);
        },
      );
      test(
        '5 mm, 40 ss 0 tenth of second',
        () {
          String timeStr = '5:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          int expectedTenthOfSeconds = 3400;
          expect(totalTenthsOfSeconds, expectedTenthOfSeconds);
        },
      );
      test(
        '5 mm, 40 ss 9 tenth of second',
        () {
          String timeStr = '5:40.9';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          int expectedTenthOfSeconds = 3409;
          expect(totalTenthsOfSeconds, expectedTenthOfSeconds);
        },
      );
      test(
        'negative 0 hh, 0 mm, 0 ss 1 tenth of second',
        () {
          const String timeStr = '-0:0:0.1';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, -1);
        },
      );
      test(
        'negative 0 hh, 0 mm, 40 ss no tenth of second',
        () {
          String timeStr = '-0:0:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, -400);
        },
      );
      test(
        'negative 0 hh, 0 mm, 40 ss 3 tenth of second',
        () {
          String timeStr = '-0:0:40.3';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, -403);
        },
      );
      test(
        'negative 0 hh, 5 mm, 40 ss 0 tenth of second',
        () {
          String timeStr = '-0:5:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          int expectedTenthOfSeconds = -3400;
          expect(totalTenthsOfSeconds, expectedTenthOfSeconds);
        },
      );
      test(
        'negative 0 hh, 5 mm, 40 ss 9 tenth of second',
        () {
          String timeStr = '-0:5:40.9';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          int expectedTenthOfSeconds = -3409;
          expect(totalTenthsOfSeconds, expectedTenthOfSeconds);
        },
      );
      test(
        'negative 0 mm, 0 ss 1 tenth of second',
        () {
          const String timeStr = '-0:0.1';
          final int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, -1);
        },
      );
      test(
        'negative 0 mm, 40 ss no tenth of second',
        () {
          String timeStr = '-0:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, -400);
        },
      );
      test(
        'negative 0 mm, 40 ss 3 tenth of second',
        () {
          String timeStr = '-0:40.3';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, -403);
        },
      );
      test(
        'negative 5 mm, 40 ss 0 tenth of second',
        () {
          String timeStr = '-5:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          int expectedTenthOfSeconds = -3400;
          expect(totalTenthsOfSeconds, expectedTenthOfSeconds);
        },
      );
      test(
        'negative 5 mm, 40 ss 9 tenth of second',
        () {
          String timeStr = '-5:40.9';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          int expectedTenthOfSeconds = -3409;
          expect(totalTenthsOfSeconds, expectedTenthOfSeconds);
        },
      );
      test(
        '2 hh, 5 mm, 40 ss 0 tenth of second',
        () {
          String timeStr = '2:5:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 75400);
        },
      );
      test(
        '2 hh, 5 mm, 40 ss 3 tenth of second',
        () {
          String timeStr = '2:5:40.3';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, 75403);
        },
      );
      test(
        'negative 2 hh, 5 mm, 40 ss 0 tenth of second',
        () {
          String timeStr = '-2:5:40';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, -75400);
        },
      );
      test(
        'negative 2 hh, 5 mm, 40 ss 3 tenth of second',
        () {
          String timeStr = '-2:5:40.3';
          int totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
          expect(totalTenthsOfSeconds, -75403);
        },
      );
    },
  );
  group(
    'DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec()',
    () {
      test(
        '0:52.4',
        () {
          const String timeStr = '0:52.4';
          expect(
            DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec(
                timeWithTenthOfSecondsStr: timeStr),
            '0:52',
          );
        },
      );
      test(
        '0:52.5',
        () {
          const String timeStr = '0:52.5';
          expect(
            DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec(
                timeWithTenthOfSecondsStr: timeStr),
            '0:53',
          );
        },
      );
      test(
        '1:45:24.4',
        () {
          const String timeStr = '1:45:24.4';
          expect(
            DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec(
                timeWithTenthOfSecondsStr: timeStr),
            '1:45:24',
          );
        },
      );
      test(
        '1:45:24.5',
        () {
          const String timeStr = '1:45:24.5';
          expect(
            DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec(
                timeWithTenthOfSecondsStr: timeStr),
            '1:45:25',
          );
        },
      );
      test(
        '1:45:24.0',
        () {
          const String timeStr = '1:45:24.0';
          expect(
            DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec(
                timeWithTenthOfSecondsStr: timeStr),
            '1:45:24',
          );
        },
      );
      test(
        '0:0:0.4',
        () {
          const String timeStr = '0:0:0.4';
          expect(
            DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec(
                timeWithTenthOfSecondsStr: timeStr),
            '0:00',
          );
        },
      );
      test(
        '0:0:0.5',
        () {
          const String timeStr = '0:0:0.5';
          expect(
            DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec(
                timeWithTenthOfSecondsStr: timeStr),
            '0:01',
          );
        },
      );
    },
  );
  group('DateTimeUtil.formatSecondsToHHMMSS()', () {
    test(
      '0',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 0), '00:00:00');
      },
    );
    test(
      '1',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 1), '00:00:01');
      },
    );
    test(
      '60',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 60), '00:01:00');
      },
    );
    test(
      '61',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 61), '00:01:01');
      },
    );
    test(
      '3600',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 3600), '01:00:00');
      },
    );
    test(
      '3601',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 3601), '01:00:01');
      },
    );
    test(
      '3661',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 3661), '01:01:01');
      },
    );
    test(
      '7200',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 7200), '02:00:00');
      },
    );
    test(
      '7260',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 7260), '02:01:00');
      },
    );
    test(
      '7261',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 7261), '02:01:01');
      },
    );
    test(
      '7320',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 7320), '02:02:00');
      },
    );
    test(
      '7321',
      () {
        expect(DateTimeUtil.formatSecondsToHHMMSS(seconds: 7321), '02:02:01');
      },
    );
  });
  group('DateTimeUtil.formatSecondsToHHMM()', () {
    test(
      '0',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 0), '00:00');
      },
    );
    test(
      '1',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 1), '00:00');
      },
    );
    test(
      '59',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 1), '00:00');
      },
    );
    test(
      '60',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 60), '00:01');
      },
    );
    test(
      '61',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 61), '00:01');
      },
    );
    test(
      '3600',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 3600), '01:00');
      },
    );
    test(
      '3601',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 3601), '01:00');
      },
    );
    test(
      '3661',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 3661), '01:01');
      },
    );
    test(
      '3719',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 3661), '01:01');
      },
    );
    test(
      '7200',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 7200), '02:00');
      },
    );
    test(
      '7260',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 7260), '02:01');
      },
    );
    test(
      '7261',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 7261), '02:01');
      },
    );
    test(
      '7320',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 7320), '02:02');
      },
    );
    test(
      '7321',
      () {
        expect(DateTimeUtil.formatSecondsToHHMM(seconds: 7321), '02:02');
      },
    );
  });
  group('DateTimeUtil.setDateTimeToEndDay()', () {
    test('setDateTimeToEndDay 0 hour', () {
      DateTime increasedValue = DateTimeUtil.setDateTimeToEndDay(
        date: DateTime(2024, 1, 7),
      );

      expect(increasedValue, DateTime(2024, 1, 7, 23, 59, 59));
    });
    test('setDateTimeToEndDay 10 hours 45 minutes 23 seconds', () {
      DateTime increasedValue = DateTimeUtil.setDateTimeToEndDay(
        date: DateTime(2024, 1, 7, 10, 45, 23),
      );

      expect(increasedValue, DateTime(2024, 1, 7, 23, 59, 59));
    });
    test('setDateTimeToEndDay 0 hours 0 minutes 23 seconds', () {
      DateTime increasedValue = DateTimeUtil.setDateTimeToEndDay(
        date: DateTime(2024, 1, 7, 0, 0, 23),
      );

      expect(increasedValue, DateTime(2024, 1, 7, 23, 59, 59));
    });
  });
}
