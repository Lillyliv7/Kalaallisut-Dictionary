import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

Future<String?> _apiRequest(String _searchTerm) async {
  // 1. Define the URL
  var url = Uri.parse('https://ordbog.gl/callback.php');
  // 2. Define the form data
  // The http package will automatically URL-encode these keys and values.
  var body = {
    'a': 'search',
    'q': _searchTerm,
    'opts[df]': '0',
    'opts[cs]': '0',
    'opts[ww]': '0',
    'opts[pm]': '1',
    'opts[xd]': '0',
    'opts[d]': '401',
  };

  try {
    // 3. Make the POST request
    var response = await http.post(url, body: body);
    // 4. Handle the response
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
//https://ordbog.gl/callback.php
  String _textValue = '';

  void _searchDatabase() {
    _apiRequest(_textValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(":D"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text('Type a completed word'),
            SizedBox(height: 15),
            Row (
              mainAxisAlignment: .center,
              children: [
                ConstrainedBox (
                  constraints: BoxConstraints(maxWidth: 300),
                  child: TextField(
                  decoration: InputDecoration(
                   border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() { _textValue = text; });
                  },
                )
                ),
                SizedBox(width: 15),
                ElevatedButton(
                  onPressed: _searchDatabase,
                  child: Text('Analyse')
                )
              ]
            ),
          ],
        ),
      )
    );
  }
}
