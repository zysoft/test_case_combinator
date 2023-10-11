// Copyright (c) 2023, Iurii Zisin. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// A small library with no dependencies that simplifies writing tests
/// where verifying all possible combinations of the input parameters
/// is required.
///
/// An example would be a function like this:
/// ```dart
/// bool isAll(bool a1, bool a2, bool a3, bool a4, bool a6) {
///   return a1 && a2 && a3 && a4 && a5 && a6;
/// }
/// ```
///
/// To fully test the function above you would need `32` test cases, where
/// only one is expected to produce the `true` result. That is a lot of test cases
/// to write, and it is easy to make a typo on the way.
///
/// This library allows easily solving a task like that by allowing
/// all test cases to be generated automatically from combinations
/// of the input parameters.
library test_case_combinator;

export 'package:test_case_combinator/src/combinator.dart';
