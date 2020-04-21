import 'dart:convert';
import 'package:http/http.dart' as http;
class Indo {
  int meninggal;
  int sembuh;
  int perawatan;
  int jumlahKasus;

  Indo({this.jumlahKasus,this.meninggal,this.perawatan,this.sembuh});

  factory Indo.fromJson(Map<String, dynamic> json){
    return Indo(
      meninggal: json["meninggal"] as int,
      sembuh: json["sembuh"] as int,
      perawatan: json["perawatan"] as int,
      jumlahKasus: json["jumlahKasus"] as int,
    );
  }
}

class IndoServices {
  static const String url = "https://indonesia-covid-19.mathdro.id/api";

  static Future<List<Indo>> getIndo() async{
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<Indo> list = parseIndo(response.body);
        return list;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Indo> parseIndo(String responseBody){
    final parsed = (json.decode(responseBody) as List).map((json) => Indo.fromJson(json)).toList();
    print(parsed);
    return parsed;
  }
  
  indoInfo() async {
    var response =  await http.get("https://indonesia-covid-19.mathdro.id/api");
    return jsonDecode(response.body);
  }
}
