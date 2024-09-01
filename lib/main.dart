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
    Directory setDirectory = Directory('${appDirectory.path}/sets');
    setDirectory.createSync();
    File sampleSet = File('${setDirectory.path}/sample_set.json');
    sampleSet.writeAsStringSync('''
{
 "version": "0.0",
 "name": "Sample Set",
 "enabled": true,
 "cards": [
   { "term": "a", "definition": "1"},
   { "term": "b", "definition": "2"},
   { "term": "c", "definition": "3"}
 ] 
}
    ''');
    for (FileSystemEntity file in setDirectory.listSync()) {
      if (file is! File) continue;
      CardSet? set = CardSet.fromFile(file);
      if (set == null) {
        print('Failed to parse file $file');
      } else {
        sets.add(set);
      }
    }
    setState(() {});
  }

  void _incrementCounter() {
    notifier.show(
        0,
        'Notification',
        'Content',
        const NotificationDetails(
            android: AndroidNotificationDetails('channel', 'Channel')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<CardSetWidget> setWidgets = [];
    for (CardSet set in sets) {
      setWidgets.add(CardSetWidget(set));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(children: setWidgets),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CardSetWidget extends StatefulWidget {
  CardSetWidget(this.set, {super.key});

  CardSet set;

  @override
  State<CardSetWidget> createState() => _CardSetWidgetState();
}

class _CardSetWidgetState extends State<CardSetWidget> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.set.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('${widget.set.name}'),
        subtitle: Text('${widget.set.cards.length} cards'),
        trailing: Switch(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
        ),
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SetEditor(widget.set)));
        });
  }
}

class SetEditor extends StatefulWidget {
  SetEditor(this.set, {super.key});

  CardSet set;
  @override
  State<SetEditor> createState() => _SetEditorState();
}

class _SetEditorState extends State<SetEditor> {
  _SetEditorState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit set')),
        body: ListView(children: []));
  }
}
