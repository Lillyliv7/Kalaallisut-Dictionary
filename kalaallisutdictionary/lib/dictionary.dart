import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'databases.dart';

String kalEngTypeToEng(String? kalEngType) {
  if (kalEngType == null) {
    return 'unknown';
  }
  if (kalEngType.toLowerCase() == "proprium/egennavn") {
    // noun
    return 'noun';
  }
  if (kalEngType.toLowerCase() == "taggit") {
    // proper noun
    return 'noun';
  }
  if (kalEngType.toLowerCase() == 'oqaluut susaatsoq') {
    // intransitive
    return 'verb';
  }
  if (kalEngType.toLowerCase() == 'oqaluut susalik') {
    // transitive
    return 'verb';
  }
  if (kalEngType.toLowerCase() == "oqaluut susaasalik") {
    // HTR
    return 'verb';
  }
  return 'unknown';
}

List<String> dictionarySearchType(String type, String term) {
  List<String> engOutputs = [];
  List<int> lengths = [];
  List<String> done = [];
  int minLength = 9999;

  for (int i = 0; i < kalEngObj['entries'].length; i++) {
    if (kalEngObj['entries'][i]['kal'].toLowerCase().startsWith(
      term.toLowerCase(),
    )) {
      if (kalEngTypeToEng(kalEngObj['entries'][i]['type']) ==
          type.toLowerCase()) {
        engOutputs.add(kalEngObj['entries'][i]['eng']);
        lengths.add(kalEngObj['entries'][i]['kal'].length);
        if (lengths[lengths.length - 1] < minLength) {
          minLength = lengths[lengths.length - 1];
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

class dictionaryPage extends StatefulWidget {
  const dictionaryPage({super.key});

  @override
  State<dictionaryPage> createState() => _dictionaryPageState();
}

class _dictionaryPageState extends State<dictionaryPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Dictionary View", style: TextStyle(fontSize: 30)),
        Expanded(child: 
          ListView.builder(
            itemExtent: 50.0, 
            itemCount: kalEngObj['entries'].length,
            // itemBuilder: (context, index) {
            //   return ListTile(
            //     leading: CircleAvatar(child: Text("${index + 1}")),
            //     title: Text(kalEngObj['entries'][index]['kal']),
            //     subtitle: const Text("Tap to view details"),
            //   );
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(kalEngObj['entries'][index]['kal']),
                  Text(kalEngObj['entries'][index]['type']),
                  Text(kalEngObj['entries'][index]['eng']),
                ],
              );
            }
          )
        )
      ],
    );
  }
}
