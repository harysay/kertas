import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kertas/pages/form_historypresensi.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/form_presensi.dart';

ApiService api = new ApiService();

class FirstFragment extends StatefulWidget {
  @override
  _FirstFragmentState createState() => _FirstFragmentState();
}

class _FirstFragmentState extends State<FirstFragment> {
  String? tarikanNamaUser = "",
      tarikanNIKUser = "",
      tarikanPangkatUser = "",
      tarikanJabatanUser = "",
      tarikNamaBidang = "",
      tarikanInstansiUser = "";
  String username = "", nama = "", tokenlogin = "";

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      tokenlogin = preferences.getString("tokenlogin")!;
      tarikanNIKUser = preferences.getString("niklogin")!;
      tarikanNamaUser = preferences.getString("namalogin")!;
      tarikNamaBidang = preferences.getString("namabidang");
      tarikanInstansiUser = preferences.getString("namaopd")!;
    });
  }
  _getRequests() async {
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  _checkIn(String masukAtauPulang) async {
    var now = DateTime.now();
    // DateFormat dateFormat = new DateFormat.Hm(now);
    var formatterTime = DateFormat('kk:mm');
    String actualTime = formatterTime.format(now);
    DateTime waktuSekarang = formatterTime.parse(actualTime);
    DateTime batasPresensiSetelah = formatterTime.parse("08:00");
    DateTime batasPresensiSebelum = formatterTime.parse("06:00");
    DateTime batasPulangSetelah = formatterTime.parse("23:59");
    DateTime batasPulangSebelum = formatterTime.parse("16:00");
    if (masukAtauPulang=="masuk"){
      if(waktuSekarang.isAfter(batasPresensiSetelah)){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Anda melebihi batas waktu presensi masuk!"),));
      }else if(waktuSekarang.isBefore(batasPresensiSebelum)){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Anda belum bisa melakukan presensi masuk!"),));
      }else{
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new FormPresensi(masukAtauPulang: masukAtauPulang)),).then((val) => val ? _getRequests() : null);
      }
    }else if(masukAtauPulang=="pulang"){
      if(waktuSekarang.isAfter(batasPulangSetelah)){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Anda melebihi batas waktu presensi pulang!"),));
      }else if(waktuSekarang.isBefore(batasPulangSebelum)){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Anda belum bisa melakukan presensi pulang!"),));
      }else{
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new FormPresensi(masukAtauPulang: masukAtauPulang)),).then((val) => val ? _getRequests() : null);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Center(
      //child: new Text("Hello Fragment 1"),
      child: Column(
        children: <Widget>[
          new Container(
              padding: new EdgeInsets.all(20.0),
              child: new Column(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Text("Nama"),
                      SizedBox(
                        width: 25.0,
                      ),
                      new Text(": "),
                      SizedBox(
                        width: 10.0,
                      ),
                      Flexible(child: new Text(tarikanNamaUser!))
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text("NIK"),
                      SizedBox(
                        width: 40.0,
                      ),
                      new Text(": "),
                      SizedBox(
                        width: 10.0,
                      ),
                      Flexible(child: new Text(tarikanNIKUser!))
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text("Bidang"),
                      SizedBox(
                        width: 20.0,
                      ),
                      new Text(": "),
                      SizedBox(
                        width: 10.0,
                      ),
                      Flexible(child: new Text(tarikNamaBidang!))
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text("Instansi"),
                      SizedBox(
                        width: 14.0,
                      ),
                      new Text(": "),
                      SizedBox(
                        width: 10.0,
                      ),
                      Flexible(child: new Text(tarikanInstansiUser!))
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(children: [
                          InkWell(
                            onTap: () {
                              _checkIn("masuk");
                            }, // Image tapped
                            splashColor:
                                Colors.white10, // Splash color over image
                            child: Ink.image(
                              fit: BoxFit.cover, // Fixes border issues
                              width: 90,
                              height: 90,
                              image: AssetImage(
                                'assets/finger_green.png',
                              ),
                            ),
                          ),
                          new Text("Check In"),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(children: [
                          InkWell(
                            onTap: () {
                              _checkIn("pulang");
                            }, // Image tapped
                            splashColor:
                                Colors.white10, // Splash color over image
                            child: Ink.image(
                              fit: BoxFit.cover, // Fixes border issues
                              width: 90,
                              height: 90,
                              image: AssetImage(
                                'assets/finger_red.png',
                              ),
                            ),
                          ),
                          new Text("Check Out"),
                        ]),
                      )
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:  const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.greenAccent, // background
                            onPrimary: Colors.orange, // foreground
                          ),
                          onPressed: () {
                            Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new HistoryPresensi()),).then((val) => val ? _getRequests() : null);
                          },
                          child: Text('History Presensi'),
                        ),)
                    ],
                  )
                ],
              )),
          // new Container(
          //     padding: new EdgeInsets.all(20.0),
          //     color: Colors.yellow[50],
          //     child: new Column(
          //       children: <Widget>[
          //         new Center(
          //           child: new Text("Data Atasan",style: styleTitle,),
          //         ),
          //         new Row(
          //           children: <Widget>[
          //             new Text("Nama"),
          //             SizedBox(width: 55.0,),
          //             new Text(": "),
          //             SizedBox(width: 10.0,),
          //             Flexible(child: new Text(tarikanNamaAtasan,))
          //           ],
          //         ),
          //         new Row(
          //           children: <Widget>[
          //             new Text("NIP"),
          //             SizedBox(width: 70.0,),
          //             new Text(": "),
          //             SizedBox(width: 10.0,),
          //             Flexible(child: new Text(tarikanNipAtasan))
          //           ],
          //         ),
          //         new Row(
          //           children: <Widget>[
          //             new Text("Jabatan"),
          //             SizedBox(width: 42.0,),
          //             new Text(": "),
          //             SizedBox(width: 10.0,),
          //             Flexible(child: new Text(tarikanJabatanAtasan))
          //           ],
          //         ),
          //         new Row(
          //           children: <Widget>[
          //             new Text("Instansi"),
          //             SizedBox(width: 44.0,),
          //             new Text(": "),
          //             SizedBox(width: 10.0,),
          //             Flexible(child: new Text(tarikanInstansiAtasan))
          //           ],
          //         )
          //       ],
          //     )
          // )
        ],
      ),
    );
  }
}
