import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kertas/pages/form_historypresensi.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../pages/form_presensi.dart';

ApiService api = new ApiService();

class FirstFragment extends StatefulWidget {
  @override
  _FirstFragmentState createState() => _FirstFragmentState();
}

class _FirstFragmentState extends State<FirstFragment> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;

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
    DateTime batasPresensiSetelah = formatterTime.parse("11:00");
    DateTime batasPresensiSebelum = formatterTime.parse("06:00");
    DateTime batasPulangSetelah = formatterTime.parse("23:59");
    DateTime batasPulangSebelum = formatterTime.parse("14:00");
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

  checkGps(String masukOrPulang) async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permissions are denied"),));
        }else if(permission == LocationPermission.deniedForever){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permissions are permanently denied"),));
          print("Location permissions are permanently denied");
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }

      if(haspermission){
        setState(() {
          //refresh the UI
        });

        _checkIn(masukOrPulang);
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("GPS Service is not enabled, turn on GPS location"),));
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2!,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    TopBox(tarikanNamaUser: tarikanNamaUser,tarikanNIKUser: tarikanNIKUser,tarikNamaBidang: tarikNamaBidang,tarikanInstansiUser: tarikanInstansiUser,),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            Ink(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Color(0xffFFEFD6),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: InkWell(
                                  onTap: () {
                                    checkGps("masuk");
                                  }, // Image tapped
                                  // splashColor: Colors.white10, // Splash color over image
                                  child: Ink.image(
                                    // fit: BoxFit.cover, // Fixes border issues
                                    width: 90,
                                    height: 90,
                                    image: AssetImage(
                                      'assets/finger_green.png',
                                    ),
                                  ),
                                )
                            ),
                            new Text("Check In"),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(children: [
                            Ink(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Color(0xffFFEFD6),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: InkWell(
                                  onTap: () {
                                    checkGps("pulang");
                                  }, // Image tapped
                                  // splashColor: Colors.white10, // Splash color over image
                                  child: Ink.image(
                                    // fit: BoxFit.cover, // Fixes border issues
                                    width: 90,
                                    height: 90,
                                    image: AssetImage(
                                      'assets/finger_red.png',
                                    ),
                                  ),
                                )
                            ),
                            new Text("Check Out"),
                          ]),
                        ),

                      ],
                    ),
                    Expanded(
                      // A flexible child that will grow to fit the viewport but
                      // still be at least as big as necessary to fit its contents.
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
//           Align(
//           alignment: Alignment.centerRight,
//           child:  TopBox()
//             ,),

                          Spacer(),
                          Container(
                              margin: EdgeInsets.all(15),
                              // color: Colors.blue,
                              decoration: BoxDecoration(
                                  color: Color(0xffFAF7F0),
                                  border: Border.all(
                                    color: Color(0xffFCDDB0),
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Silakan memilih check in untuk melakukan presensi masuk, dan check out untuk presensi pulang. Pastikan jam untuk melakukan presensi sesuai dengan ketentuan yang berlaku. Untuk pengecekan data sudah terekam atau belum bisa melalui tombol History Presensi di bawah ini")
                                        ]
                                    ),
                                  )

                              )
                          ),
                          BottomBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class TopBox extends StatelessWidget {
  String? tarikanNamaUser;
  String? tarikanNIKUser;
  String? tarikNamaBidang;
  String? tarikanInstansiUser;
  TopBox({this.tarikanNamaUser, this.tarikanNIKUser,this.tarikNamaBidang, this.tarikanInstansiUser});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      // color: Colors.blue,
      decoration: BoxDecoration(
          color: Color(0xffFAF7F0),
          border: Border.all(
            color: Color(0xffFCDDB0),
          ),
          borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      // height: 100,
      // width: 175,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
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
                ],
              ),
            ),

          ]
      ),
    );
  }
}

class BottomBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Color(0xffFFEFD6),
      decoration: BoxDecoration(
          color: Color(0xffFAF7F0),
          border: Border.all(
            color: Color(0xffFCDDB0),
          ),
          // borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      height: 60,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
              child: const Text('History Presensi',
                  style: TextStyle(fontSize: 20)),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new HistoryPresensi()),);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                minimumSize: const Size.fromHeight(50),
              )),
        ),
      )
    );
  }
}
// class MiddleBox extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }

