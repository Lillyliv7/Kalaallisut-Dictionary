import 'dart:convert';

import 'package:flutter/services.dart';

// import 'settings.dart';

var analyzerMofoObj;
var kalEngObj;
var uiStrings;


Future<bool> loadDatabases() async {
  final String analyzerMofoStr = await rootBundle.loadString('assets/analyzer-mofo.json');
  analyzerMofoObj = jsonDecode(analyzerMofoStr);

  final String kalEngStr = await rootBundle.loadString('assets/kal-eng.json');
  kalEngObj = jsonDecode(kalEngStr);

  final String uiStringsStr = await rootBundle.loadString('assets/ui-spanish.json');
  uiStrings = jsonDecode(uiStringsStr);

  print(uiStrings);

  return true;
}