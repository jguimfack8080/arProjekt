import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ar_project_app/username.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Username Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late SharedPreferences _preferences;
  bool _isUsernameEmpty = false;

  final WebSocketChannel channel = IOWebSocketChannel.connect(
      'ws://195.37.49.58:8080/ar-23-backend/api/battleship/socket/Test3');
  List<String> messages = [];
  int points = 0;
  String action = '';
  int row = 0;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadPreferences();
    channel.stream.listen((message) {
      setState(() {
        messages.add(message);
        final Map<String, dynamic> data = jsonDecode(message);
        action = data['action'] ?? '';
        
        // Update points if the server response contains "points"
        if (data.containsKey('points')) {
          points = data['points'];
          
        }

        // Update row if the server response contains "row"
        if (data.containsKey('row')) {
          row = data['row'];
        }

        _saveAction(action); // Save the action to Shared Preferences
      });
      log('Message received from server: $message');
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    channel.sink.close();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    String? savedUsername = _preferences.getString('username');

    if (savedUsername != null) {
      String? savedAppId = _preferences.getString(savedUsername);
      if (savedAppId != null) {
        setState(() {
          Username.username = savedUsername;
          Username.appId = savedAppId;
          _usernameController.text = savedUsername;
        });
      }
    }

    // Load the saved action from Shared Preferences
    String? savedAction = _preferences.getString('action');
    if (savedAction != null) {
      setState(() {
        action = savedAction;
      });
    }
  }

  String _generateAppId(String username) {
    final uuid = Uuid();
    return uuid.v4();
  }

  Future<void> _saveUsername(String username) async {
    String appId = _preferences.getString(username) ?? _generateAppId(username);
    setState(() {
      Username.username = username;
      Username.appId = appId;
      _isUsernameEmpty = false;
    });
    await _preferences.setString('username', username);
    await _preferences.setString(username, appId);
  }

  void _updateUsername(String username) {
    if (username.trim().isEmpty) {
      setState(() {
        _isUsernameEmpty = true;
      });
    } else {
      _saveUsername(username);
    }
  }


  Future<void> _saveAction(String action) async {
    await _preferences.setString('action', action);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              onChanged: _updateUsername,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                errorText: _isUsernameEmpty ? 'Username cannot be empty' : null,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Name: ${Username.username}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'App ID: ${Username.appId}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Points: $points',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Action: $action',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Row: $row',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
