library shared_preferences_moretypes;

//imports
import 'dart:core';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ExtendedPrefs {
  bool debug;
  ExtendedPrefs({this.debug = false});

  Future dataStore(String key, dynamic value) async {
    //get shared prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String type = value.runtimeType.toString();
    if (type.length >= 11) if (type.substring(0, 11) == "minified:v<")
      type = type.substring(11, type.length - 2);
    if (debug) print("store - key $key value $value");

    //set pref based on type
    if (type == "String")
      await prefs.setString(key, value);
    else if (type == "int")
      await prefs.setInt(key, value);
    else if (type == "double")
      await prefs.setDouble(key, value);
    else if (type == "bool")
      await prefs.setBool(key, value);
    else if (type.length > 4 ? type.substring(0, 4) == "List" : false) {
      if (value.length >= 0) {
        type = value[0].runtimeType.toString();
        if (type == "String")
          await prefs.setStringList(key, value);
        else {
          //type = value[0][0].runtimeType.toString();
          for (int i = 0; i < value.length; i++) {
            await dataStore("$key-$i", value[i]);
          }
          await prefs.setInt("$key+", value.length);
        }
      }
    } else if ((type.length > 22
            ? type.substring(0, 22) == "_InternalLinkedHashMap"
            : false) ||
        (type.length > 13 ? type.substring(0, 13) == "_ImmutableMap" : false)) {
      int i = 0;
      for (var k in value.keys) {
        await dataStore("$key-key$i", k);
        await dataStore("$key-value$i", value[k]);
        i++;
      }
      await prefs.setInt("$key+", value.length);
    } else {
      throw new ArgumentError.value(type, "type", "Type not supported");
    }
  }

  Future<dynamic> dataLoad(String key, String type) async {
    //get share prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    type = type.trim();

    if (debug) print("load - key $key type $type");

    //set pref based on type
    if (type == "String")
      return prefs.getString(key);
    else if (type == "int")
      return prefs.getInt(key);
    else if (type == "double")
      return prefs.getDouble(key);
    else if (type == "bool")
      return prefs.getBool(key);
    else if (type.length > 5 ? type.substring(0, 4) == "List" : false) {
      type = type.substring(5, type.length - 1);
      if (type == "String")
        return prefs.getStringList(key);
      else {
        List<dynamic> data = List.empty(growable: true);
        int length = prefs.getInt("$key+");

        for (int i = 0; i < length; i++) {
          var result = await dataLoad("$key-$i", type);
          if (i == 0) {
            switch (type) {
              case "String":
                data = List<String>.empty(growable: true);
                break;
              case "int":
                data = List<int>.empty(growable: true);
                break;
              case "double":
                data = List<double>.empty(growable: true);
                break;
              case "bool":
                data = List<bool>.empty(growable: true);
                break;
              case "List":
                data = List<List>.empty(growable: true);
                break;
              case "Map":
                data = List<Map>.empty(growable: true);
                break;
            }
          }
          data.add(result);
        }
        return data;
      }
    } else if ((type.length > 4 ? type.substring(0, 3) == "Map" : false) ||
        (type.length > 14 ? type.substring(0, 13) == "_ImmutableMap" : false) ||
        (type.length > 23
            ? type.substring(0, 22) == "_InternalLinkedHashMap"
            : false)) {
      if (type.substring(0, 3) == "Map")
        type = type.substring(4, type.length - 1);
      if (type.substring(0, 22) == "_InternalLinkedHashMap")
        type = type.substring(23, type.length - 1);
      if (type.substring(0, 13) == "_ImmutableMap")
        type = type.substring(14, type.length - 1);

      Map<dynamic, dynamic> data = <dynamic, dynamic>{};
      int length = prefs.getInt("$key+");
      List<String> types = type.split(",");

      for (int i = 0; i < length; i++) {
        dynamic k = await dataLoad("$key-key$i", types[0]);
        dynamic v = await dataLoad("$key-value$i", types[1]);
        data[k] = v;
      }
      return data;
    } else
      throw new ArgumentError.value(type, "type", "Type not supported");
  }
}
