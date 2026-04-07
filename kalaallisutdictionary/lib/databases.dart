import 'dart:convert';

import 'package:flutter/services.dart';

var analyzerMofoObj;
var kalEngObj;

void loadDatabases() async {
  final String analyzerMofoStr = await rootBundle.loadString('assets/analyzer-mofo.json');
  analyzerMofoObj = jsonDecode(analyzerMofoStr);

  final String kalEngStr = await rootBundle.loadString('assets/kal-eng.json');
  kalEngObj = jsonDecode(kalEngStr);
}