part of '../converters.dart';

extension SliderInputRangeHelpers on SliderInputRange {
  InputFieldType getInputFieldType() {
    return switch (this) {
      SliderInputRange.numbers0To99 => InputFieldType.numbers0To99,
      SliderInputRange.numbers0To999 => InputFieldType.numbers0To999,
      SliderInputRange.numbers1To999 => InputFieldType.numbers1To999,
    };
  }

  int getMinValue() {
    return switch (this) {
      SliderInputRange.numbers0To99 => 0,
      SliderInputRange.numbers0To999 => 0,
      SliderInputRange.numbers1To999 => 1,
    };
  }

  int getMaxValue() {
    return switch (this) {
      SliderInputRange.numbers0To99 => 99,
      SliderInputRange.numbers0To999 => 999,
      SliderInputRange.numbers1To999 => 999,
    };
  }
}
