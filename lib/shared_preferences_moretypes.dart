library shared_preferences_moretypes;

//imports
import 'dart:core';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ExtendedPrefs {
  bool debug;
  ExtendedPrefs({this.debug = false});

  dynamic castData(dynamic data, String type) {
    if (data == null) return null;
    switch (type) {
      case "String":
        return data.toString();
      case "int":
        return int.parse("$data");
      case "double":
        return double.parse("$data");
      case "bool":
        return data.toString() == "true"
            ? true
            : data.toString() == "false"
                ? false
                : null;
    }
    if (type.length > 4 ? type.substring(0, 4) == "List" : false) {
      if (data == null || data.length == 0) {
        return List.empty(growable: true);
      } else {
        if (type.length > 5) {
          switch (type.substring(5, type.length - 1)) {
            case "String":
              return List<String? /*!*/ >.generate(
                  data.length,
                  (index) => castData(
                      data[index], type.substring(5, type.length - 1)));
            case "int":
              return List<int?>.generate(
                  data.length,
                  (index) => castData(
                      data[index], type.substring(5, type.length - 1)));
            case "double":
              return List<double?>.generate(
                  data.length,
                  (index) => castData(
                      data[index], type.substring(5, type.length - 1)));
            case "bool":
              return List<bool?>.generate(
                  data.length,
                  (index) => castData(
                      data[index], type.substring(5, type.length - 1)));
            case "List<String>":
              return List<List<String>?>.generate(
                  data.length,
                  (index) => castData(
                      data[index], type.substring(5, type.length - 1)));
            case "List<int>":
              return List<List<int?>>.generate(
                  data.length,
                  (index) => castData(
                      data[index], type.substring(5, type.length - 1)));
            case "List<double>":
              return List<List<double?>>.generate(
                  data.length,
                  (index) => castData(
                      data[index], type.substring(5, type.length - 1)));
            case "List<bool>":
              return List<List<bool>?>.generate(
                  data.length,
                  (index) => castData(
                      data[index], type.substring(5, type.length - 1)));
          }
          return List.generate(
              data.length,
              (index) =>
                  castData(data[index], type.substring(5, type.length - 1)));
        }
      }
    } else {
      if (debug) print("cast - not happened val $data type $type");
      return data;
    }
  }

  Future<bool> dataStore(String key, dynamic value) async {
    //get shared prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String type = value.runtimeType.toString();
    String initialType = type;
    bool saved = false;

    //type minified
    if (type.length > 11 ? type.substring(0, 8) == "minified" : false)
      type = "List<${type.substring(11, type.length - 1)}>";

    if (debug) print("store - key $key value type $type");
    if (debug) print("store - value $value");

    //set pref based on type
    if (type == "String")
      saved = await prefs.setString(key, value.toString());
    else if (type == "int")
      saved = await prefs.setInt(key, value);
    else if (type == "double")
      saved = await prefs.setDouble(key, value);
    else if (type == "bool")
      saved = await prefs.setBool(key, value);
    else if (type.length > 4 ? type.substring(0, 4) == "List" : false) {
      if (value.length >= 0) {
        type = value[0].runtimeType.toString();
        if (type == "String")
          saved = await prefs.setStringList(key, value);
        else {
          //cast
          if (initialType.length > 8
              ? initialType.substring(0, 8) == "minified"
              : false) {
            value = List<dynamic>.from(value);
          }

          //type = value[0][0].runtimeType.toString();
          saved = true;
          for (int i = 0; i < value.length; i++) {
            saved &= await dataStore("$key-$i", value[i]);
          }
          saved &= await prefs.setInt("$key+", value.length);
        }
      }
    } else if ((type.length > 22
            ? type.substring(0, 22) == "_InternalLinkedHashMap"
            : false) ||
        (type.length > 13 ? type.substring(0, 13) == "_ImmutableMap" : false)) {
      int i = 0;
      saved = true;
      for (var k in value.keys) {
        saved &= await dataStore("$key-key$i", k);
        saved &= await dataStore("$key-value$i", value[k]);
        i++;
      }
      saved &= await prefs.setInt("$key+", value.length);
    } else {
      throw new ArgumentError.value(type, "type", "Type not supported");
    }
    return saved;
  }

  Future<dynamic> dataLoad(String key, String type) async {
    dynamic result = await _dataLoader(key, type);
    if (debug) print("load - value $result");
    return castData(result, type);
  }

  Future<dynamic> _dataLoader(String key, String type) async {
    //get share prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String initialType = type.toString();
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
        int length = prefs.getInt("$key+") ?? 0;

        for (int i = 0; i < length; i++) {
          var result = await dataLoad("$key-$i", type);
          if (i == 0) {
            switch (type) {
              case "String":
                data = List<String?>.empty(growable: true);
                break;
              case "int":
                data = List<int?>.empty(growable: true);
                break;
              case "double":
                data = List<double?>.empty(growable: true);
                break;
              case "bool":
                data = List<bool?>.empty(growable: true);
                break;
              case "List":
                data = List<List?>.empty(growable: true);
                break;
              case "Map":
                data = List<Map?>.empty(growable: true);
                break;
            }
          }
          data.add(result);
        }
        return castData(data, initialType);
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

      Map<dynamic, dynamic>? data = <dynamic, dynamic>{};
      int length = prefs.getInt("$key+") ?? 0;
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
