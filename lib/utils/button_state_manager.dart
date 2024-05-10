class ButtonStateManager {
  final double _minValue;
  final double _maxValue;

  ButtonStateManager({
    required double minValue,
    required double maxValue,
  })  : _minValue = minValue,
        _maxValue = maxValue;

  List<bool> getTwoButtonsState(double currentValue) {
    if (_minValue == 0 && _maxValue == 0) {
      // both buttons must be disabled when min and max value is zero,
      // i.e. when list positioned by the button's is empty, or volume
      // modification is not possible
      return [false, false];
    }

    return [
      currentValue > _minValue,
      currentValue < _maxValue,
    ];
  }
}
