import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

Future<String?> _dictionaryRequest(String _searchTerm) async {
  var url = Uri.parse('https://ordbog.gl/callback.php');
  var body = {
    'a': 'search',
    'q': _searchTerm,
    'opts[df]': '0',   // search in definitions as well
    'opts[cs]': '0',   // case sensitive
    'opts[ww]': '0',   // match whole word
    'opts[pm]': '1',   // match from start of word only
    'opts[xd]': '0',   // match diacritics exactly
    'opts[d]':  '401', // dictionary of the west greenland eskimo language, 1927
  };

  try {
    var response = await http.post(url, body: body);
    if (response.statusCode == 200) {
      print('Request successful!');
      print('Response body: ${response.body}');
      return response.body;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
  return null;
}

Future<String?> _analyzerRequest(String _URL, String _searchTerm) async {
  final url = Uri.http('localhost:8000', '/analyze', {
    'word': _searchTerm,
  });
  print(url);


  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print('Request successful!');
      print('Response body: ${response.body}');
      return response.body;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
  return null;


}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const WordAnalyserPage(),
    );
  }
}

class WordAnalyserPage extends StatefulWidget {
  const WordAnalyserPage({super.key});

  @override
  State<WordAnalyserPage> createState() => _WordAnalyserPageState();
}

class _WordAnalyserPageState extends State<WordAnalyserPage> {
  String _textValue = '';
  String _analyzerServer = '';

  void _searchDictionary() {
    // _dictionaryRequest(_textValue);

    // final analyzed = await _analyzerRequest(_analyzerServer, _textValue);
    // final analyzed_obj = jsonDecode(analyzed);
    // print(analyzed_obj);

    _analyzerRequest(_analyzerServer, _textValue).then((analyzed) {
      if (analyzed == null) {
        return;
      }
      final analyzed_obj = jsonDecode(analyzed);
      print(analyzed_obj);
    });
    

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(":D"),
      ),
      body: Center(
        child: ConstrainedBox (
          constraints: BoxConstraints(maxWidth:400),
          child:

          Column(
            mainAxisAlignment: .center,
            children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Analyzer Server (ex: localhost:8000)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() { _analyzerServer = text; });
                      },
                    ),
              SizedBox(height: 15),
              Row (
                mainAxisAlignment: .center,
                children: [
                  Expanded (
                    child: 
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter a full word',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() { _textValue = text; });
                      },
                    )),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: _searchDictionary,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(50, 50),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.pageview_outlined, size:32),
                  )
                ]
              ),
            ],
          )


        )
      )
    );
  }
}
