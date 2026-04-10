import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'databases.dart';
import 'language.dart';

const List<String> languagesList = <String>["English", "Español"];

class settingsPage extends StatefulWidget {
  const settingsPage({super.key});

  @override
  State<settingsPage> createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {
  String languageDropdown = languagesList.first;

  @override
  Widget build(BuildContext context) {
    if (preferences.getString('Language') != null) {
      languageDropdown = preferences.getString('Language');
    }
    return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(uiStrings['settings.title'], style: TextStyle(fontSize: 30)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(uiStrings['settings.language'], style: TextStyle(fontSize: 20)),
            const SizedBox(width: 15),
            DropdownButton<String>(
      value: languageDropdown,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(height: 2, color: Colors.deepPurpleAccent),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          languageDropdown = value!;
          preferences.setString('Language', languageDropdown);
          changeLanguage(languageDropdown);
        });
      },
      items: languagesList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    )
          ]
        ),
          const SizedBox(height: 50),
          Text(uiStrings['settings.credits'], style: TextStyle(fontSize: 15)),
        ],
    ));
  }
}