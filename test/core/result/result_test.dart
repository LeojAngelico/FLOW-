import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

void main() {
  test('Ok holds a value and is not an Err', () {
    const result = Result<int>.ok(42);

    expect(result, isA<Ok<int>>());
    switch (result) {
      case Ok(:final value):
        expect(value, 42);
      case Err():
        fail('expected Ok');
    }
  });

  test('Err holds a Failure', () {
    const result = Result<int>.err(StorageFailure('disk full'));

    switch (result) {
      case Ok():
        fail('expected Err');
      case Err(:final failure):
        expect(failure, isA<StorageFailure>());
        expect((failure as StorageFailure).message, 'disk full');
    }
  });

  test('ValidationFailure carries a field name and message', () {
    const failure = ValidationFailure('age', 'Age must be between 9 and 120.');

    expect(failure.field, 'age');
    expect(failure.message, 'Age must be between 9 and 120.');
  });
}
