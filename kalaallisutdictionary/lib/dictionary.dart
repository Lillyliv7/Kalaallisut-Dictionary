import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'databases.dart';



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


List<String> dictionarySearchType(String type, String term) {
  List<String> engOutputs = [];
  List<int> lengths = [];
  List<String> done = [];
  int minLength = 9999;


  for (int i = 0; i < kalEngObj['entries'].length; i++) {
    if (kalEngObj['entries'][i]['kal'].startsWith(term)) {
      if (kalEngTypeToEng(kalEngObj['entries'][i]['type']) == type.toLowerCase()) {
        engOutputs.add(kalEngObj['entries'][i]['eng']);
        lengths.add(kalEngObj['entries'][i]['kal'].length);
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




String localDictionarySearchAll(String searchTerm) {

  String toReturn = '';

  for (int i = 1; i < kalEngObj['entries'].length; i++) {
    if (kalEngObj['entries'][i]['kal'].startsWith(searchTerm)) {
      toReturn = toReturn + kalEngObj['entries'][i]['eng'] + '; ';
    }
  }

  return toReturn;
}
