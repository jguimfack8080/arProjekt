import 'package:ar_project_app/profile.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lobby_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const MyHomePage(),

      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIdx) {
      case 0:
        page = const Placeholder();
        break;
      case 1:
        page = LobbyPageList();
        break;
      case 2:
        page = ProfileScreen();
        break;

      default:
        throw Exception('No widget for $selectedIdx');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth > 500,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.directions_boat_filled,
                      color: Colors.blue,
                    ),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.groups_2, color: Colors.blue),
                    label: Text('Lobbys'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person, color: Colors.blue),
                    label: Text('Profil'),
                  ),
                ],
                selectedIndex: selectedIdx,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIdx = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}
