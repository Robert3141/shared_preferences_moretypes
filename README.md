# shared_preferences_moretypes

[![Pub](https://img.shields.io/pub/v/shared_preferences_moretypes.svg)](https://pub.dev/packages/shared_preferences_moretypes)
[![Documentation](https://img.shields.io/badge/API-reference-blue)](https://pub.dev/documentation/shared_preferences_moretypes/latest/shared_preferences_moretypes/shared_preferences_moretypes-library.html)

I wasn't able to save all the datatypes I liked so why not extend it ;)

## Datatypes supported:

- ```String```
- ```int```
- ```bool```
- ```double```
- Recursive Lists of the above (e.g ```List<double>``` ```List<double<double<double>>>``` e.t.c)
- Recursive Maps of the above (e.g ```Map<String,String>``` ```Map<String,Map<int,String>>``` e.t.c)

## Usage

save some data
```
await ExtendedPrefs().dataStore("keyS", "value");
```

load some saved data
```
await ExtendedPrefs().dataLoad("keyS", "String");
```
