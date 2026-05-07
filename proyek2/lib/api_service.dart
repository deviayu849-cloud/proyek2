import 'dart:convert';
import 'package:http/http.dart' as http;

Future getUsers() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.7:8000/api/users'),
  );

  return jsonDecode(response.body);
}