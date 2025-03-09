import 'dart:convert';

import 'package:http/http.dart' as http;

class Everyone {
  static Future<String> detectToxicity(String? str_1) async {
    Map return_data = {};
    final url = Uri.parse("http://localhost:5004/detect-toxicity");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({"text": str_1!}),
    );

    if (response.statusCode == 200) {
      final resp_data = jsonDecode(response.body);
      return resp_data["toxicity"].toString();
    } else {
      return jsonDecode(response.body)["error"].toString();
    }
  }

  static Future<String> scoreSentence(String? str_1) async {
    Map return_data = {};
    final url = Uri.parse("http://localhost:5001/score");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({"text": str_1!}),
    );

    if (response.statusCode == 200) {
      final resp_data = jsonDecode(response.body);
      print(resp_data);
      return "";
    } else {
      return jsonDecode(response.body)["error"].toString();
    }
  }

  static Future<String> factCheck(String? query) async {
    if (query == null || query.isEmpty) {
      return "Query string cannot be empty";
    }

    final url = Uri.http("127.0.0.1:5010", "/fact-check", {"query": query});

    try {
      print("cekk");
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final respData = jsonDecode(response.body);
        print(respData);
        return respData.toString();
      } else {
        final errorData = jsonDecode(response.body);
        print(errorData);
        return errorData["error"] ?? "Unknown error occurred";
      }
    } catch (e) {
      print("Error: $e");
      return "Error: $e";
    }
  }
}
