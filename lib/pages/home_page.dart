import 'package:kertas/fragments/first_fragment.dart';
import 'package:kertas/fragments/second_fragment.dart';
import 'package:kertas/fragments/third_fragment.dart';
import 'package:kertas/fragments/about_fragment.dart';
import 'package:kertas/fragments/verifikasi_fragment.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kertas/service/ApiService.dart';
import 'package:intl/intl.dart';


class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  static String tag = 'home-pages';
  final VoidCallback signOut;
  HomePage(this.signOut);


  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  var tarikanToken,tarikanLamaAktivitas,tarikanGrade;
  ApiService api = new ApiService();
  int _selectedDrawerIndex = 0;
  String username = "", nama = "", linkfoto = "", akseslev ="",idPegawai="",tahunBlnSekarang = "";
  signOut() {
    setState(() {
      widget.signOut();
    });
  }
  tahunBulanSekarang() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMM');
    String tahunBlnSekarang = formatter.format(now);
    return tahunBlnSekarang;
  }
  Future<Null> _getLamaAktivitas()async{
    // setState(() {
    // ApiService lamamenit = new ApiService();
    // tarikanLamaAktivitas  =  lamamenit.getLamaAktivitas(idPegawai, tahunBlnSekarang);
    // });
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // setState(() {
    //   tarikanToken = preferences.getString("tokenlogin");
    // });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if(preferences.containsKey("niklogin")) {
        idPegawai = preferences.getString("id")!;
        username = preferences.getString("niklogin")!;
        nama = preferences.getString("namalogin")!;
        linkfoto = preferences.getString("fotoLogin")!;
        akseslev = preferences.getString("akseslevel")!;
        tarikanToken = preferences.getString("tokenlogin");
        if (akseslev == "1" || akseslev == "2") {} else {
          drawerItems.removeAt(2);
        }
      }else{
        setState(() {
          this.initState();
        });
      }
    });
    ApiService lamamenit = new ApiService();
    // var now = new DateTime.now();
    // var formatter = new DateFormat('yyyyMM');
    // tahunBlnSekarang = formatter.format(now);
    final response = await http.get(Uri.parse(lamamenit.baseLamaAktivitas+idPegawai),
     headers: {
       "Accept": "application/json",
       "Content-Type": "application/x-www-form-urlencoded",
       "authorization": tarikanToken
     },);
    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      setState(() {
        tarikanLamaAktivitas = data["total_menit"];
      });
    }else{
      Text("Error bro");
    }

    //
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // setState(() {
    //   tarikanToken = preferences.getString("tokenlogin");
    // });
    // final response = await http.get(Uri.parse(api.urlGetdataPribadi+"MTk3MDA4MjgxOTk3MDMxMDEy"));
    // if(response.statusCode == 200){
    //   final data = jsonDecode(response.body);
    //   //final _daftarPekerjaan = data['data'];
    //   setState(() {
    //     tarikanLamaAktivitas = data["data"]["lama_aktivitas"];
    //     tarikanGrade = data["data"]["grade"];
    //   });
    // }else{
    //   Text("error bro");
    // }
  }

  final drawerItems = [
    new DrawerItem("Dashboard", Icons.home),
    new DrawerItem("Rekam Aktivitas", Icons.add_alarm),
    new DrawerItem("Verifikasi Aktivitas", Icons.check_circle_outline),
    new DrawerItem("Laporan", Icons.calendar_today),
    new DrawerItem("Tentang Aplikasi", Icons.help_outline),
    new DrawerItem("Keluar", Icons.call_missed_outgoing)
  ];


  // getPref() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     if(preferences.containsKey("niklogin")) {
  //       idPegawai = preferences.getString("id")!;
  //       username = preferences.getString("niklogin")!;
  //       nama = preferences.getString("namalogin")!;
  //       linkfoto = preferences.getString("fotoLogin")!;
  //       akseslev = preferences.getString("akseslevel")!;
  //       tarikanToken = preferences.getString("tokenlogin");
  //       if (akseslev == "1" || akseslev == "2") {} else {
  //         drawerItems.removeAt(2);
  //       }
  //     }else{
  //       setState(() {
  //         this.initState();
  //       });
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // getPref();
    _getLamaAktivitas();
  }

  _getDrawerItemWidget(int pos) {
    if(akseslev=="1"||akseslev=="2"){
      switch (pos) {
        case 0:
          return new FirstFragment();
        case 1:
          return new SecondFragment();
        case 2:
          return new VerifikasiFragment();
        case 3:
          return new ThirdFragment();
        case 4:
          return new AboutFragment();
        case 5:
          return signOut();

        default:
          return new Text("Error");
      }
    }else{
      switch (pos) {
        case 0:
          return new FirstFragment();
        case 1:
          return new SecondFragment();
        case 2:
          return new ThirdFragment();
        case 3:
          return new AboutFragment();
        case 4:
          return signOut();

        default:
          return new Text("Error");
      }
    }

  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return new Scaffold(
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: new Text(drawerItems[_selectedDrawerIndex].title),
      ),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text(nama),
//              accountEmail: new Text(username),
              accountEmail: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(username),
                      Row(children: <Widget>[
                        Text('Telah bekerja: '),
                        Text(tarikanLamaAktivitas??'Tidak terdefinisi'),
                        Text(' mnt'),
                      ],),
                      // Row(children: <Widget>[
                      //   Text('Grade: '),
                      //   Text(tarikanGrade??'tidak terdefinisi'),
                      // ],)
                    ],
                  ),

                ],
              ),

              currentAccountPicture:
              new CircleAvatar(
                backgroundImage: new NetworkImage(linkfoto),
              ),decoration: new BoxDecoration(
                  // color: Colors.deepOrange[300]
                color: Colors.blueAccent
            ),
              otherAccountsPictures: <Widget>[

              ],
            ),
            new Column(children: drawerOptions)

          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}
