// Copyright (c) 2023, Iurii Zisin. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// An argument for [TestCaseCombinator], that provides the values
/// the argument could take, and a function which applies a particular
/// value to the resulting test case [T].
///
/// See [TestCaseCombinator] for an example.
typedef TestCaseCombinatorArgument<T> = (
  Iterable<dynamic> values,
  T Function(T, dynamic) applicator,
);

/// Builder for test cases based on all possible combinations of the input arguments.
///
/// Very useful for the cases when you need test cases covering all possible input
/// parameter combinations.
///
/// Example:
///
/// We need to test the following code:
/// ```dart
/// enum Food {
///   apple,
///   banana,
///   yoghurt,
/// }
///
/// class Monkey {
///   final bool stomachFull;
///
///   const Monkey({
///     this.stomachFull = false,
///   });
///
///   bool shouldEat(Food food) {
///     if (stomachFull) return false;
///     return food == Food.banana;
///   }
/// }
/// ```
/// Specifically, we're interested in `shouldEat` functionality.
///
/// Based on the logic we can see in `shouldEat`, we can determine that if monkey is
/// given some food, it will only eat banana, but it will reject even a banana
/// if it is already full.
///
/// Given that, we can determine that one condition is boolean (`stomachFull`), that
/// can take **2** values - `true` and `false`.
/// Another condition is `Food`, which has **3** options - `apple`, `banana`, and `yoghurt`.
///
/// This gives us **6** combinations total that we have to check.
/// From those combinations we only have **1** case when monkey will eat the food - if it's
/// stomach is not full and it's given a banana.
///
/// This is a perfect example when writing all cases by hand is a lot of time and effort,
/// complex readability, and a significant probability of introducing errors.
///
/// Instead, we can use [TestCaseCombinator] to make all the combinations for us:
/// ```dart
/// final _monkeyTestCases = TestCaseCombinator<({bool stomachFull, Food food})>(
///   (stomachFull: false, food: Food.apple),
///   [
///     ([true, false], (input, value) => (stomachFull: value, food: input.food)),
///     (Food.values, (input, value) => (stomachFull: input.stomachFull, food: value)),
///   ],
/// )
///   ..successfulCase((stomachFull: false, food: Food.banana));
/// ```
///
/// Now we can write our test:
/// ```dart
/// void main() {
///   group('Verify monkey eating food', () {
///     for (var testCase in _monkeyTestCases.testCases) {
///       test(testCase.description, () {
///         final monkey = Monkey(stomachFull: testCase.input.stomachFull);
///         expect(monkey.shouldEat(testCase.input.food), testCase.isSuccessful,
///             reason: testCase.isSuccessful
///                 ? 'Monkey is expected to eat ${testCase.input.food.name} when it is ${testCase.input.stomachFull ? 'full' : 'hungry'}'
///                 : 'Monkey should not eat ${testCase.input.food.name} when it is ${testCase.input.stomachFull ? 'full' : 'hungry'}');
///       });
///     }
///   });
/// }
/// ```
///
/// The test goes over all [testCases], created by [TestCaseCombinator] and sets up a test for each one,
/// where each test case provides a record with a particular input, in our case a record containing the stomach flag
/// with some food, a description of the test case itself (example: `true | Food.apple`), and `isSuccessful` flag, indicating
/// if the test case is considered successful (from the test perspective).
///
/// The only thing we had to do is add the actual expectation to our test.
///
/// The test will be called with the following parameters:
///
///  stomachFull |     food     |   isSuccessful
///  :---------: | :----------: | :--------------:
///     true     | Food.apple   |     false
///     true     | Food.banana  |     false
///     true     | Food.yoghurt |     false
///     false    | Food.apple   |     false
///     false    | Food.banana  |     true
///     false    | Food.yoghurt |     false
///
/// That provided a pretty comprehensive testing of `shouldEat` method, covering all possible cases.
///
/// Now we can be sure the monkey is always eating healthy!
///
class TestCaseCombinator<T> {
  /// Creates the combinator with [initialValue] which will be used for taking
  /// all possible combinations of [arguments].
  TestCaseCombinator(
    T initialValue,
    List<TestCaseCombinatorArgument<T>> arguments,
  ) {
    _testCases.addAll(_combinations(initialValue, arguments).toSet());
  }

  /// Set of test cases, each being a record of a `record` and a `description`.
  ///
  /// `testCase` represents a particular combination of arguments
  final Set<({T value, String description})> _testCases = {};

  /// A set of cases set by calling [successfulCase].
  final Set<T> _successfulCases = {};

  /// A synchronous generator which recursively builds all possible combinations from
  /// the given [arguments], starting from [initialValue] and producing a record with
  /// the combination applied to [initialValue] and a description showing the combination
  /// itself.
  ///
  // Based on https://stackoverflow.com/a/68816233
  Iterable<({T value, String description})> _combinations(
    T initialValue,
    List<TestCaseCombinatorArgument<T>> arguments, [
    int position = 0,
    T? testCase,
    List<String>? argList,
  ]) sync* {
    testCase ??= initialValue;
    argList ??= [];

    if (arguments.length == position) {
      yield (value: testCase as T, description: argList.join(' | '));
    } else {
      for (final value in arguments[position].$1) {
        yield* _combinations(
          initialValue,
          arguments,
          position + 1,
          arguments[position].$2(
            testCase as T,
            value,
          ),
          argList..add(value.toString()),
        );
        argList.removeLast();
      }
    }
  }

  /// Provides a [testCase] which indicates a successful case (for the test).
  ///
  /// In other words, that is a case when test would expect a success.
  void successfulCase(T testCase) {
    _successfulCases.add(testCase);
  }

  /// Runs a comparator against all [testCases] and adds matching
  /// cases as successful.
  ///
  /// This is helpful when verifying a specific condition in a large set of
  /// combinations, where the rest of variables do not matter.
  ///
  /// Be careful if you chain multiple [successfulCaseIf] calls per
  /// set of test cases .
  ///
  /// Consider the example below:
  /// ```dart
  /// final testCases = TestCaseCombinator<(bool, bool)>(
  ///   (false, false),
  ///   [
  ///     ([true, false], (r, v) => (v, r.$2)),
  ///     ([true, false], (r, v) => (r.$1, v)),
  ///   ]
  /// )
  ///   ..successfulCaseIf((testCase) => testCase.$1)
  ///   ..successfulCaseIf((testCase) => testCase.$2);
  /// ```
  ///
  /// The example above will effectively add all test cases as successful, which may not
  /// be desired.
  void successfulCaseIf(bool Function(T) comparator) {
    for (final testCase in _testCases) {
      if (!comparator(testCase.value)) continue;
      _successfulCases.add(testCase.value);
    }
  }

  /// Provides all test cases where each test case provides the `input`, `description`, and
  /// `isSuccessful` flag, indicating if this test case is expected to be a success.
  ///
  /// Test cases order is not guaranteed to be the same across calls.
  Iterable<({T input, bool isSuccessful, String description})> get testCases {
    return _testCases.map((testCase) => (
          input: testCase.value,
          isSuccessful: _successfulCases.contains(testCase.value),
          description: testCase.description,
        ));
  }
}
