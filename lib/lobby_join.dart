import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:ar_project_app/username.dart';

class Lobby {
  final String lobbyName;
  final List<String> users;

  Lobby({
    required this.lobbyName,
    required this.users,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    return Lobby(
      lobbyName: json['lobbyName'] ?? '',
      users: List<String>.from(
          json['users']?.map((user) => user['userName']) ?? []),
    );
  }
}

class LobbyPage extends StatefulWidget {
  final String lobbyName;

  LobbyPage({required this.lobbyName});

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final TextEditingController usernameController = TextEditingController();
  UnityWidgetController? _unityWidgetController;
  bool showUnityInterface = false;
  late String appId;
  String username = '';
  List<String> messages = [];
  String action = '';
  int points = 0;

  @override
  void initState() {
    super.initState();

    appId = Username.appId;
    username = Username.username;
    usernameController.text = username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showUnityInterface
          ? null
          : AppBar(
              title: Text('Lobby: ${widget.lobbyName}'),
            ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              if (!showUnityInterface)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      readOnly: true,
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'App ID',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      controller: TextEditingController(text: appId),
                    ),
                    SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        joinLobby(context);
                      },
                      child: Text('Lobby beitreten als Spieler'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        joinLobbyAsSpectator(context);
                      },
                      child: Text('Lobby beitreten als Zuschauer'),
                    ),
                  ],
                ),
              if (showUnityInterface)
                Stack(
                  children: [
                    UnityWidget(
                      onUnityCreated: onUnityCreated,
                      onUnityMessage: onUnityMessage,
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: () {
                          if (showUnityInterface) {
                            sendMessageFromFlutterToUnity("Hello Check");
                          }
                        },
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.navigation),
                      ),
                    ),
                  ],
                ),
              if (messages.isNotEmpty)
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          'Messages from Server:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return Text(messages[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onUnityCreated(controller) {
    _unityWidgetController = controller;
  }

  void onUnityMessage(message) {
    log("Received message from Unity: ${message.toString()}");
  }

  void sendMessageFromFlutterToUnity(String message) {
    _unityWidgetController?.postMessage('EchoTest', 'echoTest', message);
    log("Sent message to Unity: $message");
  }

  Future<void> joinLobby(BuildContext context) async {
    final url = Uri.parse(
        'http://195.37.49.58:8080/ar-23-backend/api/battleship/enter');
    final headers = {'Content-Type': 'application/json'};
    final username = usernameController.text.trim();

    if (username.isEmpty) {
      showErrorDialog(context, 'Geben Sie bitte einen Benutzernamen ein');
      return;
    }

    final body = jsonEncode({
      'lobbyName': widget.lobbyName,
      'appId': appId,
      'username': username,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final socketURL = responseData['socketURL'];

      final WebSocketChannel channel = IOWebSocketChannel.connect(socketURL);
      int totalPoints = 0; // Variable pour stocker le total des points

      channel.stream.listen((message) {
        setState(() {
          messages.add(message);
          final Map<String, dynamic> data = jsonDecode(message);
          if (data.containsKey('points')) {
            final int pointsReceived = data['points'];
            final String appIdServer = data['appId'];

            if (appIdServer == appId) {
              totalPoints += pointsReceived;
              log('Points reçus : $pointsReceived');
              log('Total des points : $totalPoints');
            } else {
              log('L\'appId renvoyé par le serveur ne correspond pas à l\'appId de l\'utilisateur');
            }
          }
        });
      });

      print('Erfolgreich der Lobby ${widget.lobbyName} beigetreten.');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erfolgreich beigetreten'),
          content: Text('Sie sind der Lobby ${widget.lobbyName} beigetreten.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

      setState(() {
        showUnityInterface = true;
      });
    } else {
      final errorMessage =
          'Fehler beim Beitreten der Lobby ${widget.lobbyName}. Statuscode: ${response.statusCode}';
      print(errorMessage);
      showErrorDialog(context, errorMessage);
    }
  }

  Future<void> joinLobbyAsSpectator(BuildContext context) async {
    final url = Uri.parse(
        'http://195.37.49.58:8080/ar-23-backend/api/battleship/spectate');
    final headers = {'Content-Type': 'application/json'};
    final username = usernameController.text.trim();

    if (username.isEmpty) {
      showErrorDialog(context, 'Geben Sie bitte einen Benutzernamen ein');
      return;
    }

    final body = jsonEncode({
      'lobbyName': widget.lobbyName,
      'appId': appId,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final socketURL = responseData['socketURL'];

      final channel = IOWebSocketChannel.connect(socketURL);
      channel.stream.listen((message) {
        print('Eingehende Nachricht: $message');
      });

      print(
          'Erfolgreich der Lobby ${widget.lobbyName} als Zuschauer beigetreten.');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erfolgreich beigetreten'),
          content: Text(
              'Sie sind der Lobby ${widget.lobbyName} als Zuschauer beigetreten.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

      setState(() {
        showUnityInterface = true;
      });
    } else {
      final errorMessage =
          'Fehler beim Beitreten der Lobby ${widget.lobbyName} als Zuschauer. Statuscode: ${response.statusCode}';
      print(errorMessage);
      showErrorDialog(context, errorMessage);
    }
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Fehler beim Beitreten'),
        content: Text(errorMessage),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
