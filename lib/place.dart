import 'dart:convert';
import 'package:http/http.dart' as http;

class Ship {
  final int size;
  final int row;
  final int column;
  final bool horizontal;

  Ship({required this.size, required this.row, required this.column, required this.horizontal});

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'row': row,
      'column': column,
      'horizontal': horizontal,
    };
  }
}

Future<void> sendShipPlacement(String lobbyName, String appId, List<Ship> ships) async {
  final url = 'http://195.37.49.58:8080/ar-23-backend/api/battleship/place';

  final requestBody = jsonEncode({
    'lobbyName': lobbyName,
    'appId': appId,
    'ships': ships.map((ship) => ship.toJson()).toList(),
  });

  try {
    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody);

    if (response.statusCode == 200) {
      // Schiffsplatzierung erfolgreich
      print('Schiffsplatzierung erfolgreich');
    } else {
      // Fehler bei der Schiffsplatzierung
      print('Fehler bei der Schiffsplatzierung');
    }
  } catch (e) {
    // Fehler bei der Kommunikation mit dem Backend
    print('Fehler bei der Kommunikation mit dem Backend');
  }
}
