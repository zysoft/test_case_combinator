A small library with no dependencies that simplifies writing tests where verifying all possible combinations of the input parameters is required.

## Getting started

Add a line like this to your package's `pubspec.yaml` and run `flutter pub get` or `dart pub get`:

```yaml
dev_dependencies:
  test_case_combinator: ^1.0.0
```

## Usage

Imagine we need to test the following code:

```dart
enum Food {
  apple,
  banana,
  yoghurt,
}
class Monkey {
  final bool stomachFull;
  const Monkey({
    this.stomachFull = false,
  });
  bool shouldEat(Food food) {
    if (stomachFull) return false;
    return food == Food.banana;
  }
}
```

Specifically, we're interested in `shouldEat` functionality.

Based on the logic we can see in `shouldEat`, we can determine that if a monkey is given some food, it will only eat banana, but it will reject even a banana if it is already full.

Given that, we can determine that one condition is boolean (`stomachFull`), that can take **2** values - `true` and `false`.
Another condition is `Food`, which has **3** options - `apple`, `banana`, and `yoghurt`.

This gives us **6** combinations total that we have to check.
From those combinations we only have **1** case when monkey will eat the food - if it's stomach is not full and it's given a banana.

This is a perfect example when writing all cases by hand is a lot of time and effort, complex readability, and a significant probability of introducing errors.

Instead, we can use [TestCaseCombinator] to make all the combinations for us:

```dart
final _monkeyTestCases = TestCaseCombinator<({bool stomachFull, Food food})>(
  (stomachFull: false, food: Food.apple), 
  [
    ([true, false], (input, value) => (stomachFull: value, food: input.food)),
    (Food.values, (input, value) => (stomachFull: input.stomachFull, food: value)),
  ],
)
  ..successfulCase((stomachFull: false, food: Food.banana));
```

Now we can write our test:

```dart
void main() {
  group('Verify monkey eating food', () {
    for (var testCase in _monkeyTestCases.testCases) {
      test(testCase.description, () {
        final monkey = Monkey(stomachFull: testCase.input.stomachFull);
        expect(monkey.shouldEat(testCase.input.food), testCase.isSuccessful,
            reason: testCase.isSuccessful
                ? 'Monkey is expected to eat ${testCase.input.food.name} when it is ${testCase.input.stomachFull ? 'full' : 'hungry'}'
                 : 'Monkey should not eat ${testCase.input.food.name} when it is ${testCase.input.stomachFull ? 'full' : 'hungry'}');
      });
    }
  });
}
```

The test goes over all [testCases], created by [TestCaseCombinator] and sets up a test for each one, 
where each test case provides a record with a particular input, in our case a record containing the stomach flag
with some food, a description of the test case itself (example: `true | Food.apple`), and `isSuccessful` flag, indicating 
if the test case is considered successful (from the test perspective).

The only thing we had to do is add the actual expectation to our test.

The test will be called with the following parameters:

 stomachFull |     food     |   isSuccessful
 :---------: | :----------: | :--------------:
    true     | Food.apple   |     false
    true     | Food.banana  |     false
    true     | Food.yoghurt |     false
    false    | Food.apple   |     false
    false    | Food.banana  |     true
    false    | Food.yoghurt |     false

That provided a pretty comprehensive testing of `shouldEat` method, covering all possible cases.

Now we can be sure the monkey is always eating healthy!

## Acknowledgements

Thanks to [HealthFleet](https://www.healthfleet.com) for supporting this project!

*<small>
Kindly be aware that the acknowledgments are provided solely for informational purposes and do not constitute an endorsement or establish any formal legal relationship between the aforementioned companies or individuals and the project or its authors.</small>*