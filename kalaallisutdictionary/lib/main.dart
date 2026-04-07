import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'analyzer.dart';
import 'blockWidget.dart';
import 'dictionary.dart';

void main() {
  runApp(const MyApp());
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
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

  String _textValue = '';
  String _analyzerServer = '';
  
  // Changed from List<String> to List<ParsedWord>
  List<ParsedWord> _cleanedAnalyses = [];

  void _searchDictionary() {
    setState(() {
        _cleanedAnalyses = [];
      });
    analyzerRequest(_analyzerServer, _textValue).then((analyzed) {
      if (analyzed == null) {
        setState(() {
          _cleanedAnalyses = [];
        });
        return;
      }
      final analyzedObj = jsonDecode(analyzed);
      final analyses = analyzedObj['analyses'] as List<dynamic>?;
      
      // Store the actual ParsedWord objects instead of turning them into strings
      final cleaned = analyses?.map((a) => parseAnalyzerOutput(a['cleaned'] as String)).toList() ?? [];
      setState(() {
        _cleanedAnalyses = cleaned.cast<ParsedWord>();
      });
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _wordController.dispose();
    super.dispose();
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
                const TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Tab(icon: Icon(Icons.pageview_outlined)), // word lookup
                    Tab(icon: Icon(Icons.library_books)),     // dictionary view
                    Tab(icon: Icon(Icons.reorder)),           // flashcards
                    Tab(icon: Icon(Icons.settings)),          // settings
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Word Lookup", style: TextStyle(fontSize: 30)),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  controller: _serverController,
                                  decoration: const InputDecoration(
                                    hintText: 'Analyzer Server (ex: localhost:8000)',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      _analyzerServer = text;
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _wordController,
                                        decoration: const InputDecoration(
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
                                    const SizedBox(width: 15),
                                    ElevatedButton(
                                      onPressed: _searchDictionary,
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(50, 50),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
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
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // Render the custom widget for each analysis
                              children: _cleanedAnalyses.map(
                                (parsedWord) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ParsedWordWidget(word: parsedWord),
                                ),
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Dictionary View", style: TextStyle(fontSize: 30))],
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Flashcards", style: TextStyle(fontSize: 30))],
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Settings", style: TextStyle(fontSize: 30))],
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