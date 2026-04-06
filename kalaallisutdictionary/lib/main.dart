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
class ParsedWordWidget extends StatefulWidget {
  final ParsedWord word;

  const ParsedWordWidget({Key? key, required this.word}) : super(key: key);

  @override
  State<ParsedWordWidget> createState() => _ParsedWordWidgetState();
}

class _ParsedWordWidgetState extends State<ParsedWordWidget> {
  late Future<String?> _definitionFuture;

  @override
  void initState() {
    super.initState();
    _definitionFuture = _dictionaryRequest(widget.word.root.text);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _definitionFuture,
      builder: (context, snapshot) {
        String definition = "Loading Definition...";
        if (snapshot.hasError) {
          definition = "Failed to load definition";
        } else if (snapshot.connectionState == ConnectionState.done) {
          definition = snapshot.data ?? "No definition found";
        }

        return Wrap(
          spacing: 6.0,
          runSpacing: 8.0,
          children: [
            // 1. Root Block
            _MorphBlock(
              text: widget.word.root.text,
              // Now uses the loaded definition
              tooltipText: 'Root (${widget.word.root.type})\n$definition',
              backgroundColor: Colors.blue.shade100,
              borderColor: Colors.blue.shade400,
            ),
            
            // 2. Affix Blocks
            ...widget.word.affixes.map((affix) => _MorphBlock(
              text: affix.text,
              tooltipText: affix.joinEffect,
              backgroundColor: Colors.green.shade100,
              borderColor: Colors.green.shade400,
            )),

            // 3. Ending Block
            _MorphBlock(
              text: '-${widget.word.ending.tags.first}',
              tooltipText: 'Ending\n${widget.word.ending.tags.join(" + ")}',
              backgroundColor: Colors.orange.shade100,
              borderColor: Colors.orange.shade400,
            ),
          ],
        );
      },
    );
  }
}

class _MorphBlock extends StatelessWidget {
  final String text;
  final String tooltipText;
  final Color backgroundColor;
  final Color borderColor;

  const _MorphBlock({
    required this.text,
    required this.tooltipText,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipText,
      padding: const EdgeInsets.all(12.0),
      textStyle: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
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
    // 'opts[d]': '401', // dictionary of the west greenland eskimo language, 1927
    'opts[d]': '402' // Greenlandic-English Dictionary, 2019
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
  
  // Changed from List<String> to List<ParsedWord>
  List<ParsedWord> _cleanedAnalyses = [];

  void _searchDictionary() {
    setState(() {
        _cleanedAnalyses = [];
      });
    _analyzerRequest(_analyzerServer, _textValue).then((analyzed) {
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