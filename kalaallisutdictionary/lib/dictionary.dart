import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<String?> localDictionarySearch(String searchTerm) async {
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

// Currently unused due to local dictionary copy

// Future<String?> dictionaryRequest(String searchTerm) async {
//   var url = Uri.parse('https://ordbog.gl/callback.php');
//   var body = {
//     'a': 'search',
//     'q': searchTerm,
//     'opts[df]': '0', // search in definitions as well
//     'opts[cs]': '0', // case sensitive
//     'opts[ww]': '0', // match whole word
//     'opts[pm]': '1', // match from start of word only
//     'opts[xd]': '0', // match diacritics exactly
//     // 'opts[d]': '401', // dictionary of the west greenland eskimo language, 1927
//     'opts[d]': '402' // Greenlandic-English Dictionary, 2019
//   };

//   try {
//     var response = await http.post(url, body: body);
//     if (response.statusCode == 200) {
//       print('Request successful!');
//       print('Response body: ${response.body}');
//       final regex = RegExp(r'<div\s+lang=\\"en\\"\s+class=\\"lang-eng\\"> : ([\s\S]*?)<\/div>');
//       final matches = regex.allMatches(response.body);
//       String res = '';
//       for (final m in matches) {
//         // print(m.group(1)); // Prints "Dart", "is", "fun"
//         res = res + m.group(1)! + '; ';
//       }
//       // return response.body;
//       return res;
//     } else {
//       print('Request failed with status: ${response.statusCode}.');
//     }
//   } catch (e) {
//     print('An error occurred: $e');
//   }
//   return null;
// }