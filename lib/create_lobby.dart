import 'dart:convert';
import 'package:ar_project_app/username.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lobby Creation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LobbyCreationPage(),
    );
  }
}

class LobbyCreationPage extends StatefulWidget {
  @override
  _LobbyCreationPageState createState() => _LobbyCreationPageState();
}

class _LobbyCreationPageState extends State<LobbyCreationPage> {
  final String apiUrl = 'http://195.37.49.58:8080/ar-23-backend/api/battleship/create';

  TextEditingController lobbyNameController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userNameController.text = Username.username;
  }

  Future<void> createLobby() async {
    String lobbyName = lobbyNameController.text;
    String userName = Username.username;
    String appId = Username.appId;

    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, String> body = {
      'lobbyName': lobbyName,
      'appId': appId,
      'username': userName,
    };
    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: jsonEncode(body));

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        String socketURL = responseData['socketURL'];
        String lobbyName = responseData['lobbyName'];
        int rows = responseData['rows'];
        int columns = responseData['columns'];
        List<Map<String, dynamic>> ships = List.from(responseData['ships']);

        print('Lobby wurde erfolgreich erstellt!');
        print('Socket URL: $socketURL');
        print('Lobby Name: $lobbyName');
        print('Rows: $rows');
        print('Columns: $columns');
        print('Ships: $ships');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Lobby erfolgreich erstellt'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Socket URL: $socketURL'),
                  Text('Lobby Name: $lobbyName'),
                  Text('Rows: $rows'),
                  Text('Columns: $columns'),
                  Text('Ships: $ships'),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Fehler beim Erstellen der Lobby. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Bei der HTTP-Anfrage ist eine Exception aufgetreten. $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Neue Lobby')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: lobbyNameController,
              decoration: InputDecoration(labelText: 'Lobbyname'),
            ),
            TextField(
              controller: _userNameController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: Username.appId),
              decoration: InputDecoration(labelText: 'App ID'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: createLobby,
              child: Text('Lobby erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
