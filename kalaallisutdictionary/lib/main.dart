import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  final examples = [
    'sinip+Gram/IV+TAR+Der/vv+Gram/IV+VIK+Der/vn+N+Abs+Sg',
    'illu+QAR+Der/nv+Gram/IV+Gram/IV+VIK+Der/vn+N+Trm+Sg',
    'ilior+Gram/IV+Gram/IV+USIQ+Der/vn+QAR+Der/nv+GramIV+Gram/IV+VIK+Der/vn+GE+Der/nv+Gram/TV+NIAR+Der/vv+Gram/TV+V+Cont+3SgO',
    'oqalup+UTE+Der/vv+Gram/TV+Gram/TV+V+Ind+1Sg+3SgO'
  ];

  for (var i = 0; i < examples.length; i++) {
    print('--- Example ${i + 1} ---');
    print('Raw: ${examples[i]}\n');
    final parsed = parseAnalyzerOutput(examples[i]);
    print(parsed);

  }

  runApp(const MyApp());
}








class ParsedWord {
  final Root root;
  final List<Affix> affixes;
  final Ending ending;

  ParsedWord({
    required this.root,
    required this.affixes,
    required this.ending,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('1. Root: $root');
    buffer.writeln('2. Affixes:');
    if (affixes.isEmpty) {
      buffer.writeln('   (None)');
    } else {
      for (var affix in affixes) {
        buffer.writeln('   - $affix');
      }
    }
    buffer.writeln('3. Ending: $ending');
    return buffer.toString();
  }
}

class Root {
  final String text;
  final String type; // Noun, Verb, etc.
  final List<String> markers;

  Root(this.text, this.type, this.markers);

  @override
  String toString() {
    final markerStr = markers.isNotEmpty ? ' [Markers: ${markers.join(' + ')}]' : '';
    return '$text ($type)$markerStr';
  }
}

class Affix {
  final String text;
  final List<String> markers;

  Affix(this.text, this.markers);

  /// Translates the derivation tag into a readable join marker
  String get joinEffect {
    for (var m in markers) {
      if (m == 'Der/nv') return 'Noun -> Verb';
      if (m == 'Der/vn') return 'Verb -> Noun';
      if (m == 'Der/vv') return 'Verb -> Verb';
      if (m == 'Der/nn') return 'Noun -> Noun';
    }
    return 'Modifiers/Grammar Only';
  }

  @override
  String toString() {
    return '$text ($joinEffect) -> tags: ${markers.join(' + ')}';
  }
}

class Ending {
  final List<String> tags;

  Ending(this.tags);

  @override
  String toString() => tags.join(' + ');
}

/// Main parser function
ParsedWord parseAnalyzerOutput(String input) {
  final tokens = input.split('+');
  if (tokens.isEmpty) throw ArgumentError('Input cannot be empty');

  final String rootText = tokens.first;
  final List<String> rootMarkers = [];
  final List<Affix> affixes = [];
  final List<String> endingTags = [];

  String? currentAffixText;
  List<String> currentAffixMarkers = [];
  bool inEnding = false;

  // Helper to verify if a token is ALL CAPS (ignores symbols)
  bool isAllCaps(String s) {
    return s == s.toUpperCase() && s.contains(RegExp(r'[A-ZÆØÅ]'));
  }

  for (int i = 1; i < tokens.length; i++) {
    final token = tokens[i];

    // If we have transitioned into the ending, just collect the remaining tags
    if (inEnding) {
      endingTags.add(token);
      continue;
    }

    // Determine if this token marks the start of the final inflectional ending.
    // Rule: It is an ending base (like N or V) AND no 'Der/' tags appear after it.
    if (['N', 'V', 'PTCL', 'NUM', 'PRON'].contains(token)) {
      final hasSubsequentDer = tokens.skip(i + 1).any((t) => t.startsWith('Der/'));
      if (!hasSubsequentDer) {
        inEnding = true;
        
        // Save the last processed affix before entering the ending
        if (currentAffixText != null) {
          affixes.add(Affix(currentAffixText, currentAffixMarkers));
          currentAffixText = null;
        }
        
        endingTags.add(token);
        continue;
      }
    }

    if (isAllCaps(token) && !token.startsWith('Gram/')) {
      // We found a new Affix. Save the previous one if it exists.
      if (currentAffixText != null) {
        affixes.add(Affix(currentAffixText, currentAffixMarkers));
      }
      currentAffixText = token;
      currentAffixMarkers = [];
    } else {
      // It's a grammatical or derivation marker
      if (currentAffixText != null) {
        currentAffixMarkers.add(token);
      } else {
        rootMarkers.add(token);
      }
    }
  }

  // Catch any dangling affix if an ending wasn't explicitly found
  if (currentAffixText != null) {
    affixes.add(Affix(currentAffixText, currentAffixMarkers));
  }

  // Determine if the Root is a Noun or a Verb
  String rootType = 'Unknown';
  
  // 1. Check root markers for Explicit Verb grammar
  if (rootMarkers.any((m) => m.contains('IV') || m.contains('TV') || m.contains('V'))) {
    rootType = 'Verb';
  } 
  // 2. If no explicit root markers, reverse-engineer from the first affix's join condition
  else if (affixes.isNotEmpty) {
    final firstDer = affixes.first.markers.firstWhere(
        (m) => m.startsWith('Der/'), orElse: () => '');
    if (firstDer == 'Der/nv' || firstDer == 'Der/nn') {
      rootType = 'Noun';
    } else if (firstDer == 'Der/vn' || firstDer == 'Der/vv') {
      rootType = 'Verb';
    }
  } 
  // 3. If there are no affixes, look at the ending part of speech
  else if (endingTags.isNotEmpty) {
    if (endingTags.first == 'N') rootType = 'Noun';
    if (endingTags.first == 'V') rootType = 'Verb';
  }

  return ParsedWord(
    root: Root(rootText, rootType, rootMarkers),
    affixes: affixes,
    ending: Ending(endingTags),
  );
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
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

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
          analyses?.map((a) => parseAnalyzerOutput(a['cleaned']).toString() as String).toList() ?? [];
      setState(() {
        _cleanedAnalyses = cleaned;
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
                                  controller: _serverController,
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
                                        controller: _wordController,
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
