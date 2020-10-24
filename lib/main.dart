// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: RandomWords(),
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = List<String>();
  final _biggerFont = TextStyle(fontSize: 18.0);
  var _saved = List<String>();

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  _loadSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _saved = (prefs.getStringList('saved') ?? []);
    });
  }

  _addSaved(String entryName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _saved.add(entryName);
      prefs.setStringList('saved', _saved);
    });
  }

  _removeSaved(String entryName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _saved.remove(entryName);
      prefs.setStringList('saved', _saved);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _navigateToSaved)
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _navigateToSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Saved Suggestions'),
          ),
          body: ListView.builder(
            itemCount: _saved.length,
            itemBuilder: (context, index) {
              final item = _saved[index];

              return Dismissible(
                key: Key(item),

                onDismissed: (direction) {
                  setState(() {
                    _removeSaved(item);
                  });

                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("$item dismissed")));
                },
                // Show a red background as the item is swiped away.
                background: Container(color: Colors.red),
                child: ListTile(title: Text('$item', style: _biggerFont)),
              );
            },
          ),
        );
      },
    ));
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: EdgeInsets.all(18.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(
                generateWordPairs().take(10).map((pair) => pair.asPascalCase));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(String entryName) {
    final alreadySaved = _saved.contains(entryName);
    return ListTile(
      title: Text(
        entryName,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          alreadySaved ? _removeSaved(entryName) : _addSaved(entryName);
        });
      },
    );
  }
}
