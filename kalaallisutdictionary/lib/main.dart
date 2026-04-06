import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

Future<String?> _dictionaryRequest(String searchTerm) async {
  var url = Uri.parse('https://ordbog.gl/callback.php');
  var body = {
    'a': 'search',
    'q': searchTerm,
    'opts[df]': '0', // search in definitions as well
    'opts[cs]': '0', // case sensitive
    'opts[ww]': '0', // match whole word
    'opts[pm]': '1', // match from start of word only
    'opts[xd]': '0', // match diacritics exactly
    'opts[d]': '401', // dictionary of the west greenland eskimo language, 1927
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

Future<String?> _analyzerRequest(String URL, String searchTerm) async {
  final url = Uri.http('localhost:8000', '/analyze', {'word': searchTerm});
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
      title: 'Kalaallisut Dictionary',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
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
  List<String> _cleanedAnalyses = [];

  void _searchDictionary() {
    _analyzerRequest(_analyzerServer, _textValue).then((analyzed) {
      if (analyzed == null) {
        setState(() {
          _cleanedAnalyses = [];
        });
        return;
      }
      final analyzedObj = jsonDecode(analyzed);
      final analyses = analyzedObj['analyses'] as List<dynamic>?;
      final cleaned =
          analyses?.map((a) => a['cleaned'] as String).toList() ?? [];
      setState(() {
        _cleanedAnalyses = cleaned;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Center(
          child: SafeArea(
            child: Column(
              children: [
                TabBar(
                  labelColor:
                      Colors.black, // Required if no AppBar theme is present
                  tabs: [
                    Tab(icon: Icon(Icons.pageview_outlined)), // word lookup
                    Tab(icon: Icon(Icons.library_books)), // dictionary view
                    Tab(icon: Icon(Icons.reorder)), // flashcards
                    Tab(icon: Icon(Icons.settings)), // settings
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "Word Lookup",
                            style: TextStyle(fontSize: 30)
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 400),
                            child: Column(
                              mainAxisAlignment: .center,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    hintText:
                                        'Analyzer Server (ex: localhost:8000)',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      _analyzerServer = text;
                                    });
                                  },
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Enter a full word',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (text) {
                                          setState(() {
                                            _textValue = text;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    ElevatedButton(
                                      onPressed: _searchDictionary,
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(50, 50),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.pageview_outlined,
                                        size: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _cleanedAnalyses
                                  .map(
                                    (line) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: Text(
                                        line,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "Dictionary View",
                            style: TextStyle(fontSize: 30)
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "Flashcards",
                            style: TextStyle(fontSize: 30)
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "Settings",
                            style: TextStyle(fontSize: 30)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
