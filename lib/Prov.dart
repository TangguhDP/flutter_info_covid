import 'dart:convert';
import 'package:http/http.dart' as http;
class Prov {
  int fid;
  int kodeProvi;
  String provinsi;
  int kasusPosi;
  int kasusSemb;
  int kasusMeni;
  Prov({this.fid,this.kodeProvi,this.provinsi,this.kasusPosi,this.kasusSemb,this.kasusMeni});

  factory Prov.fromJson(Map<String, dynamic> json){
    return Prov(
      fid: json["fid"] as int,
      kodeProvi: json["kodeProvi"] as int,
      provinsi: json["provinsi"] as String,
      kasusPosi: json["kasusPosi"] as int,
      kasusSemb: json["kasusSemb"] as int,
      kasusMeni: json["kasusMeni"] as int,
    );
  }
}

class ProvServices {
  static const String url = "https://indonesia-covid-19.mathdro.id/api/provinsi";

  static Future<List<Prov>> getProv() async{
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<Prov> list = parseProvs(response.body);
        return list;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  static List<Prov> parseProvs(String responseBody){
    final parsed =json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
    // print(parsed.map<Prov>((json) => Prov.fromJson(json)));
    return parsed.map<Prov>((json) => Prov.fromJson(json)).toList();
  }
}
