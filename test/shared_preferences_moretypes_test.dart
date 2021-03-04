import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_moretypes/shared_preferences_moretypes.dart';

void main() async {
  const List<dynamic>? testValues = [
    "value",
    3,
    true,
    4.7,
    ["value1", "value2", "value3"],
    [5, 7, 3],
    [true, true, false, true],
    [3.0, 7.2, 56.5],
    [
      [30, 72, 564],
      [434, 32424, 2345],
      [4343343434, 343434333333, 4444553333]
    ],
    [
      [3.0, 7.2, 56.4],
      [43.4, 3242.4, 234.5],
      [434.3343434, 343434.333333, 444455.3333]
    ],
    {"firstK": "firstV", "secondK": "secondV"},
    {2: "helium", 10: "neon", 18: "argon"}
  ];
  const List<dynamic>? notSupportedValues = [
    null,
    [null],
    {null}
  ];

  var prefs = ExtendedPrefs(debug: true);

  // working values
  for (int i = 0; i < testValues.length; i++) {
    test("Test value: ${testValues[i]}", () async {
      await prefs.dataStore("testVal$i", testValues[i]);
      expect(
          await prefs.dataLoad(
              "testVal$i", testValues[i].runtimeType.toString()),
          testValues[i]);
    });
  }

  // Errors
  for (int i = 0; i < notSupportedValues.length; i++) {
    test("Error value: ${notSupportedValues[i]}", () async {
      try {
        await prefs.dataStore("testError$i", notSupportedValues[i]);
        await prefs.dataLoad(
            "testError$i", notSupportedValues[i].runtimeType.toString());
      } on ArgumentError catch (e) {
        expect(e.message, "Type not supported");
        return;
      }
    });
  }
  //test blank list
  test("Test load empty List", () async {
    expect(await prefs.dataLoad('blankList', 'List<bool>'), []);
  });
}
