import 'package:audiolearn/utils/button_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ButtonStateManager', () {
    test('should enable both buttons when current value is between min and max', () {
      final buttonStateManager = ButtonStateManager(minValue: 0, maxValue: 10);
      final result = buttonStateManager.getTwoButtonsState(5);
      expect(result, equals([true, true]));
    });

    test('should disable decrement button when current value equals min value', () {
      final buttonStateManager = ButtonStateManager(minValue: 0, maxValue: 10);
      final result = buttonStateManager.getTwoButtonsState(0);
      expect(result, equals([false, true]));
    });

    test('should disable increment button when current value equals max value', () {
      final buttonStateManager = ButtonStateManager(minValue: 0, maxValue: 10);
      final result = buttonStateManager.getTwoButtonsState(10);
      expect(result, equals([true, false]));
    });

    test("should disable both buttons when min and max value is zero, i.e. when list positioned by the button's is empty, or volume modification is not possible", () {
      final buttonStateManager = ButtonStateManager(minValue: 0, maxValue: 0);
      final result = buttonStateManager.getTwoButtonsState(11);
      expect(result, equals([false, false]));
    });
  });
}
