import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

String kalEngTypeToEng(String kalEngType) {
  if (kalEngType == "taggit") {
    return 'noun';
  }
  if (kalEngType == 'oqaluut susaatsoq') { // intransitive
    return 'verb';
  }
  if (kalEngType == 'oqaluut susalik') { // transitive
    return 'verb';
  }
  return 'other';
}


Future<List<String>> dictionarySearchType(String type, String term) async {
  List<String> engOutputs = [];
  List<int> lengths = [];
  List<String> done = [];
  int minLength = 9999;

  final String jsonString = await rootBundle.loadString('assets/kal-eng.json');

  var decoded = jsonDecode(jsonString);

  for (int i = 0; i < decoded['entries'].length; i++) {
    if (decoded['entries'][i]['kal'].startsWith(term)) {
      if (kalEngTypeToEng(decoded['entries'][i]['type']) == type.toLowerCase()) {
        engOutputs.add(decoded['entries'][i]['eng']);
        lengths.add(decoded['entries'][i]['kal'].length);
        if (lengths[lengths.length-1] < minLength) {
          minLength = lengths[lengths.length-1];
        }
      }
    }
  }

  for (int i = 0; i < engOutputs.length; i++) {
    if (lengths[i] == minLength) {
      done.add(engOutputs[i]);
    }
  }

  return done;
}




Future<String?> localDictionarySearchAll(String searchTerm) async {
  final String jsonString = await rootBundle.loadString('assets/kal-eng.json');

  var decoded = jsonDecode(jsonString);

  String toReturn = '';

  for (int i = 1; i < decoded['entries'].length; i++) {
    if (decoded['entries'][i]['kal'].startsWith(searchTerm)) {
      toReturn = toReturn + decoded['entries'][i]['eng'] + '; ';
    }
  }

  return toReturn;
}
