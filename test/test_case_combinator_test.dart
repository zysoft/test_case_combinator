// Copyright (c) 2023, Iurii Zisin. All rights reserved. 
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// A test ensuring that [TestCaseCombinator] works correctly.

import 'package:test/test.dart';
import 'package:test_case_combinator/test_case_combinator.dart';

void main() {
  group('TestCaseCombinator', () {
    test('creates all possible combinations', testCombinationProducing);
    test('properly marks cases as successful', testSuccessfulCombinations);
    test('properly marks case as successful dynamically', testSuccessfulIf);
  });
}

/// Verifies that [TestCaseCombinator] produces the complete set of
/// combinations.
void testCombinationProducing() {
  final combinator = TestCaseCombinator<(int, int)>(
    (0, 0),
    [
      ([0, 1, 2], (record, value) => (value, record.$2)),
      ([0, 1, 2], (record, value) => (record.$1, value)),
    ],
  );

  expect(
    combinator.testCases.length,
    9,
    reason: 'Expected to produce 9 test cases',
  );

  final testCases = combinator.testCases.toSet();

  final expectedTestCases = <_TestCase>{
    (input: (0, 0), isSuccessful: false, description: '0 | 0'),
    (input: (0, 1), isSuccessful: false, description: '0 | 1'),
    (input: (0, 2), isSuccessful: false, description: '0 | 2'),
    (input: (1, 0), isSuccessful: false, description: '1 | 0'),
    (input: (1, 1), isSuccessful: false, description: '1 | 1'),
    (input: (1, 2), isSuccessful: false, description: '1 | 2'),
    (input: (2, 0), isSuccessful: false, description: '2 | 0'),
    (input: (2, 1), isSuccessful: false, description: '2 | 1'),
    (input: (2, 2), isSuccessful: false, description: '2 | 2'),
  };
  for (final expectedCase in expectedTestCases) {
    expect(
      testCases,
      contains(expectedCase),
      reason: 'Combination $expectedCase is expected to be generated',
    );
  }
}

/// Verifies that providing successful cases results in
/// properly marking them in [TestCaseCombinator.testCases].
void testSuccessfulCombinations() {
  final combinator = TestCaseCombinator<(int, int)>(
    (0, 0),
    [
      ([0, 1, 2], (record, value) => (value, record.$2)),
      ([0, 1, 2], (record, value) => (record.$1, value)),
    ],
  )..successfulCase((1, 2));

  for (final testCase in combinator.testCases) {
    final expectedSuccess = testCase.input == (1, 2);
    expect(
      testCase.isSuccessful,
      expectedSuccess,
      reason:
          'Case ${testCase.input} is expected to ${expectedSuccess ? 'succeed' : 'fail'}',
    );
  }
}

/// Uses [TestCaseCombinator.successfulCaseIf] to make subset of combinations
/// successful based on a comparison function.
void testSuccessfulIf() {
  final combinator = TestCaseCombinator<(int, int)>(
    (0, 0),
    [
      ([0, 1, 2], (record, value) => (value, record.$2)),
      ([0, 1, 2], (record, value) => (record.$1, value)),
    ],
  )..successfulCaseIf((testCase) => testCase.$2 == 1);

  final testCases = combinator.testCases.toSet();

  final expectedTestCases = <_TestCase>[
    (input: (0, 1), isSuccessful: true, description: '0 | 1'),
    (input: (1, 1), isSuccessful: true, description: '1 | 1'),
    (input: (2, 1), isSuccessful: true, description: '2 | 1'),
  ];

  for (final expectedCase in expectedTestCases) {
    var expectedMatcher = contains(expectedCase);
    if (!expectedCase.isSuccessful) {
      expectedMatcher = isNot(expectedMatcher);
    }
    expect(
      testCases,
      expectedMatcher,
      reason:
          'Combination $expectedCase is expected to be ${expectedCase.isSuccessful ? 'successful' : 'failed'}',
    );
  }
}

/// A complete test case record.
typedef _TestCase = ({(int, int) input, bool isSuccessful, String description});
