import 'package:flutter/material.dart';
import 'dart:async';
import 'Prov.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid19 Info App',
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

indoInfo() async {
  var response = await http.get("https://indonesia-covid-19.mathdro.id/api");
  return jsonDecode(response.body);
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _debouncer = Debouncer(milliseconds: 500);
  List<Prov> provs = List();
  List<Prov> filteredProvs = List();

  @override
  void initState() {
    super.initState();
    ProvServices.getProv().then((provFromApi) {
      setState(() {
        provs = filteredProvs = provFromApi;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indonesia Covid-19'),
        backgroundColor: Colors.red[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
                future: indoInfo(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: Text("Waiting for data"),
                    );
                  } else {
                    var indoInfo = snapshot.data;
                    return Column(
                      children: <Widget>[
                        ListTile(
                            colorStart: Colors.blue[700],
                            colorEnd: Colors.blue[200],
                            counter: indoInfo["jumlahKasus"],
                            title: 'Total Kasus',
                            emoji: '😷'),
                        ListTile(
                            colorStart: Colors.green[700],
                            colorEnd: Colors.green[200],
                            counter: indoInfo["sembuh"],
                            title: 'Total Penyintas',
                            emoji: '😄'),
                        ListTile(
                            colorStart: Colors.red,
                            colorEnd: Colors.red[200],
                            counter: indoInfo["meninggal"],
                            title: 'Total Kematian',
                            emoji: '💀'),
                      ],
                    );
                  }
                }),
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                onChanged: (value) {
                  _debouncer.run(() {
                    setState(() {
                      filteredProvs = provs
                          .where((u) => (u.provinsi
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              u.kodeProvi
                                  .toString()
                                  .contains(value.toLowerCase())))
                          .toList();
                    });
                  });
                },
                decoration: InputDecoration(
                  labelText: "Cari Provinsi",
                  hintText: "Cari Provinsi",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[500]),
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 180.0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredProvs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ProvinceTile(
                      name: filteredProvs[index].provinsi,
                      kasusPosi: filteredProvs[index].kasusPosi,
                      kasusMeni: filteredProvs[index].kasusMeni,
                      kasusSemb: filteredProvs[index].kasusSemb,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class ProvinceTile extends StatelessWidget {
  ProvinceTile({this.name, this.kasusPosi, this.kasusMeni, this.kasusSemb});
  final String name;
  final int kasusPosi;
  final int kasusMeni;
  final int kasusSemb;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      margin: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            spreadRadius: 1.0,
            offset: Offset(2.0, 2.0),
          )
        ],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name,
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5.0,
            ),
            Divider(height: 2.0, thickness: 2.0, color: Colors.black26),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  kasusPosi.toString(),
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(" Total kasus",
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w400)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  kasusSemb.toString(),
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(" Sudah sembuh",
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w400)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  kasusMeni.toString(),
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(" Telah meninggal",
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ListTile extends StatelessWidget {
  ListTile(
      {this.colorStart, this.colorEnd, this.counter, this.title, this.emoji});
  final Color colorStart;
  final Color colorEnd;
  final int counter;
  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      width: double.infinity,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(
              5.0,
              5.0,
            ),
          )
        ],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        gradient: LinearGradient(
            colors: [colorStart, colorEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            tileMode: TileMode.clamp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    counter.toString(),
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  )
                ],
              )),
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  emoji,
                  style: TextStyle(fontSize: 30.0, color: Colors.white70),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
