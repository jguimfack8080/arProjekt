import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'create_lobby.dart';
import 'lobby_join.dart';

class LobbyPageList extends StatefulWidget {
  @override
  _LobbyPageListState createState() => _LobbyPageListState();
}

class _LobbyPageListState extends State<LobbyPageList> {
  List<Lobby> lobbyList = [];

  @override
  void initState() {
    super.initState();
    fetchLobbyList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SeasideAR'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LobbyCreationPage(),
                ),
              ).then((value) {
                if (value != null && value) {
                  fetchLobbyList();
                }
              });
            },
            child: Text('Lobby erstellen'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lobbyList.length,
              itemBuilder: (context, index) {
                final lobby = lobbyList[index];
                return ListTile(
                  title: Text(
                    lobby.lobbyName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text('Users: ${lobby.users.join(", ")}'),
                  trailing: IconButton(
                    icon: Icon(Icons.login, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LobbyPage(lobbyName: lobby.lobbyName),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchLobbyList() async {
    final url = Uri.parse('http://195.37.49.58:8080/ar-23-backend/api/battleship/list');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> lobbyDataList = responseData as List<dynamic>;

        setState(() {
          lobbyList = lobbyDataList
              .map<Lobby>((lobbyData) => Lobby.fromJson(lobbyData))
              .toList();
        });
      } else {
        print('Fehler beim Abrufen der Lobbyliste. Statuscode: ${response.statusCode}');
      }
    } catch (e) {
      print('Fehler beim Verbinden mit dem Server: $e');
    }
  }
}
