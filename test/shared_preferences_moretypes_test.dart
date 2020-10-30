import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_moretypes/shared_preferences_moretypes.dart';

void main() async {
  /*test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
    expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });*/

  var prefs = ExtendedPrefs();

  test("String", () async {
    await prefs.dataStore("keyS", "value");
    expect(await prefs.dataLoad("keyS", "String"), "value");
  });
  test("int", () async {
    await prefs.dataStore("keyI", 3);
    expect(await prefs.dataLoad("keyI", "int"), 3);
  });
  test("bool", () async {
    await prefs.dataStore("keyB", true);
    expect(await prefs.dataLoad("keyB", "bool"), true);
  });
  test("double", () async {
    await prefs.dataStore("keyD", 4.7);
    expect(await prefs.dataLoad("keyD", "double"), 4.7);
  });
  test("List<String>", () async {
    await prefs.dataStore("keyLS", ["value1", "value2", "value3"]);
    expect(await prefs.dataLoad("keyLS", "List<String>"),
        ["value1", "value2", "value3"]);
  });
  test("List<double>", () async {
    await prefs.dataStore("keyLD", [3.0, 7.2, 56.5]);
    expect(await prefs.dataLoad("keyLD", "List<double>"), [3.0, 7.2, 56.5]);
  });

  test("List<List<double>>", () async {
    await prefs.dataStore("keyLLD", [
      [3.0, 7.2, 56.4],
      [43.4, 3242.4, 234.5],
      [434.3343434, 343434.333333, 444455.3333]
    ]);
    expect(await prefs.dataLoad("keyLLD", "List<double<double>>"), [
      [3.0, 7.2, 56.4],
      [43.4, 3242.4, 234.5],
      [434.3343434, 343434.333333, 444455.3333]
    ]);
  });
}
