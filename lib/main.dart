import 'dart:convert';

import 'set.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Sets:'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> files = [];
  List<CardSet> sets = [];
  FlutterLocalNotificationsPlugin notifier = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    notifier.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('launch_background')));
    _initializeFiles();
  }

  void _initializeFiles() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    Directory setDirectory = Directory('${appDirectory.path}/sets')
      ..createSync();
//     File sampleSet = File('${setDirectory.path}/sample_set.json');
//     sampleSet.writeAsStringSync('''
// {
//  "version": "0.0",
//  "name": "Sample Set",
//  "enabled": true,
//  "cards": [
//    { "term": "a", "definition": "1"},
//    { "term": "b", "definition": "2"},
//    { "term": "c", "definition": "3"}
//  ]
// }
//     ''');
    // for (FileSystemEntity file in setDirectory.listSync()) {
    //   if (file is! File) continue;
    //   CardSet? set = CardSet.fromFile(file);
    //   if (set == null) {
    //     print('Failed to parse file $file');
    //   } else {
    //     sets.add(set);
    //   }
    // }
    files = setDirectory.listSync().whereType<File>().toList();
    // TODO: Implement resilient handling of unparsable files
    // sets = files.map((file) => CardSet.fromFile(file)!).toList();

    setState(() {});
  }

  void _incrementCounter() {
    notifier.show(
        0,
        'Notification',
        'Content',
        const NotificationDetails(
            android: AndroidNotificationDetails('channel', 'Channel')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) => CardSetWidget(files[index]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CardSetWidget extends StatefulWidget {
  const CardSetWidget(this.file, {super.key});

  final File file;

  @override
  State<CardSetWidget> createState() => _CardSetWidgetState();
}

class _CardSetWidgetState extends State<CardSetWidget> {
  late CardSet set;

  @override
  void initState() {
    super.initState();
    // TODO: Implement resilient parsing
    set = CardSet.fromFile(widget.file)!;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(set.name),
        subtitle: Text('${set.cards.length} cards'),
        trailing: Switch(
          value: set.enabled,
          onChanged: (value) {
            setState(() {
              set.enabled = value;
            });
            widget.file.writeAsStringSync(set.toJson());
          },
        ),
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SetEditor(widget.file, set)))
              .then((value) {
            setState(() {});
          });
        });
  }
}

class SetEditor extends StatefulWidget {
  const SetEditor(this.file, this.set, {super.key});

  final File file;
  final CardSet set;

  @override
  State<SetEditor> createState() => _SetEditorState();
}

class _SetEditorState extends State<SetEditor> {
  @override
  void initState() {
    super.initState();
    edited = CardSet.from(widget.set);
    // Change JSON format when updated
    // edited.version = '0.0';
  }

  late CardSet edited;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit set'), actions: [
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            widget.file.writeAsStringSync(edited.toJson());
            // There's probably a more elegant way to do this.
            // Maybe by returning a CardSet object when the route is popped?
            widget.set.version = edited.version;
            widget.set.name = edited.name;
            widget.set.cards = edited.cards;
          },
        )
      ]),
      body: Column(children: [
        TextField(
            controller: TextEditingController(text: edited.name),
            onChanged: (text) {
              edited.name = text;
            }),
        Expanded(
            child: ListView.builder(
                itemCount: edited.cards.length,
                itemBuilder: (context, index) => Card(
                        child: Row(children: [
                      Expanded(
                        child: Column(children: [
                          TextField(
                            controller: TextEditingController(
                                text: edited.cards[index].term),
                            onChanged: (text) {
                              edited.cards[index].term = text;
                            },
                          ),
                          TextField(
                            controller: TextEditingController(
                                text: edited.cards[index].definition),
                            onChanged: (text) {
                              edited.cards[index].definition = text;
                            },
                          ),
                        ]),
                      ),
                      IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              edited.cards.removeAt(index);
                            });
                          })
                    ]))))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            edited.cards.add(FlashCard('', ''));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
