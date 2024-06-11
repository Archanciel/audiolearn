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

          timeStr = '0:40';
          totalTenthsOfSeconds =
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

          timeStr = '0:40.3';
          totalTenthsOfSeconds =
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

          timeStr = '5:40';
          totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
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

          timeStr = '5:40.9';
          totalTenthsOfSeconds =
              DateTimeUtil.convertToTenthsOfSeconds(timeString: timeStr);
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
}
