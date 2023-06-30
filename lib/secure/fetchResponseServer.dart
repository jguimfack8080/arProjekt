import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FetchResponseServer extends StatefulWidget {
  @override
  _FetchResponseServerState createState() => _FetchResponseServerState();
}

class _FetchResponseServerState extends State<FetchResponseServer> {
  final WebSocketChannel channel = IOWebSocketChannel.connect('ws://195.37.49.58:8080/ar-23-backend/api/battleship/socket/Test3');
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    channel.stream.listen((message) {
      setState(() {
        messages.add(message);
      });
      log('Message from server: $message'); 
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('WebSocket Example'),
        ),
        body: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(messages[index]),
            );
          },
        ),
      ),
    );
  }
}
