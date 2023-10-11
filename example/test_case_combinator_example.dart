import 'package:test/test.dart';
import 'package:test_case_combinator/test_case_combinator.dart';

/// Food that can be given to a monkey.
enum Food {
  apple,
  banana,
  yoghurt,
}

/// Monkey that can eat food.
class Monkey {
  const Monkey({this.stomachFull = false});

  /// Indicates if the monkey is full.
  final bool stomachFull;

  /// Returns `true` if [food] can be eaten.
  bool shouldEat(Food food) {
    if (stomachFull) return false;
    return food == Food.banana;
  }
}

final _monkeyTestCases = TestCaseCombinator<({bool stomachFull, Food food})>(
  (stomachFull: false, food: Food.apple),
  [
    ([true, false], (input, value) => (stomachFull: value, food: input.food)),
    (
      Food.values,
      (input, value) => (stomachFull: input.stomachFull, food: value)
    ),
  ],
)..successfulCase((stomachFull: false, food: Food.banana));

void main() {
  group('Verify monkey eating food', () {
    // For every generated test case
    for (var testCase in _monkeyTestCases.testCases) {
      // We define a test
      test(testCase.description, () {
        // which makes Monkey instance with the test case input
        final monkey = Monkey(stomachFull: testCase.input.stomachFull);
        // And then verifies the the test case expectation is met
        expect(monkey.shouldEat(testCase.input.food), testCase.isSuccessful,
            reason: testCase.isSuccessful
                ? 'Monkey is expected to eat ${testCase.input.food.name} whe it is ${testCase.input.stomachFull ? 'full' : 'hungry'}'
                : 'Monkey should not eat ${testCase.input.food.name} whe it is ${testCase.input.stomachFull ? 'full' : 'hungry'}');
      });
    }
  });
}
