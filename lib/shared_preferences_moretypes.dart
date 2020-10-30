library shared_preferences_moretypes;

//imports
import 'dart:core';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ExtendedPrefs {
  Future dataStore(String key, dynamic value) async {
    //get shared prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String type = value.runtimeType.toString();
    //print("store - key $key value $value");

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
      if (value.length > 0) {
        type = value[0].runtimeType.toString();
        if (type == "String")
          await prefs.setStringList(key, value);
        else if (type == "double" || type == "int" || type == "bool") {
          List<String> raw = List.empty(growable: true);
          for (int i = 0; i < value.length; i++) {
            raw.add(type == "bool"
                ? value[i]
                    ? "1"
                    : "0"
                : value[i].toString());
          }
          await prefs.setStringList(key, raw);
        } else {
          type = value[0][0].runtimeType.toString();
          for (int i = 0; i < value.length; i++) {
            await dataStore("$key-$i", value[i]);
          }
          await prefs.setInt(key, value.length);
        }
      }
    } else {
      throw ("Type not supported $type");
    }
  }

  Future<dynamic> dataLoad(String key, String type) async {
    //get share prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //print("load - key $key type $type");

    //set pref based on type
    if (type == "String")
      return prefs.getString(key);
    else if (type == "int")
      return prefs.getInt(key);
    else if (type == "double")
      return prefs.getDouble(key);
    else if (type == "bool")
      return prefs.getBool(key);
    else if (type.substring(0, 4) == "List") {
      type = type.substring(5, type.length - 1);
      if (type == "String")
        return prefs.getStringList(key);
      else if (type == "double" || type == "int" || type == "bool") {
        List<String> raw = prefs.getStringList(key);
        if (type == "double") {
          List<double> data = List.empty(growable: true);
          for (int i = 0; i < raw.length; i++) {
            data.add(double.parse(raw[i]));
          }
          return data;
        }
        if (type == "int") {
          List<int> data = List.empty(growable: true);
          for (int i = 0; i < raw.length; i++) {
            data.add(int.parse(raw[i]));
          }
          return data;
        }
        if (type == "bool") {
          List<bool> data = List.empty(growable: true);
          for (int i = 0; i < raw.length; i++) {
            data.add(raw[i] == "1");
          }
          return data;
        }
      } else if (type.split("<").length > 1) {
        List<dynamic> data = List.empty(growable: true);
        int length = prefs.getInt(key);
        //find next <
        for (int i = 0; i < type.length - 1; i++) {
          if (type[i] == "<") {
            type = "List<" + type.substring(i + 1);
          }
        }
        for (int i = 0; i < length; i++) {
          data.add(await dataLoad("$key-$i", type));
        }
        return data;
      } else
        throw ("Type not supported $type");
    } else
      throw ("Type not supported $type");
  }
}
