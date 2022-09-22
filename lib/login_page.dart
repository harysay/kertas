import 'dart:convert';
import 'package:kertas/pages/maintenancePage.dart';
import 'package:flutter/material.dart';
import 'package:kertas/pages/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:kertas/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(new MaterialApp(
    title: "Aplikasi E-kertas",
    home: new LoginPage(),
//    routes: <String, WidgetBuilder>{
//      '/hallogin': (BuildContext context) => new LoginPage(),
//      '/haldashboard': (BuildContext context) => new HomePage(),
//    }
  ));
}

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginPageState extends State<LoginPage> {

  Map<int, Color> color =
  {
    50:Color.fromRGBO(136,14,79, .1),
    100:Color.fromRGBO(136,14,79, .2),
    200:Color.fromRGBO(136,14,79, .3),
    300:Color.fromRGBO(136,14,79, .4),
    400:Color.fromRGBO(136,14,79, .5),
    500:Color.fromRGBO(136,14,79, .6),
    600:Color.fromRGBO(136,14,79, .7),
    700:Color.fromRGBO(136,14,79, .8),
    800:Color.fromRGBO(136,14,79, .9),
    900:Color.fromRGBO(136,14,79, 1),
  };

  // setelah buat enum LoginStatus, buat kondisi default
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String? statusRun,tokenStatus;
  SharedPreferences? sharedPreferences;
  String username="", password="";
  final _key = new GlobalKey<FormState>();

  // membuat show hide password
  bool _secureText = true;
  showhide() {
    // jika kondisinya true _secureText kan berubah jadi false
    // jika kondisinya false _secureText kan berubah jadi true
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() async {
    final form = _key.currentState;

    // jika formnya valid dan tidak ada yg ksong maka akan di save
    if (form!.validate()) {
      form!.save();
      ApiService login = new ApiService();
      await login.loginAplikasi(username,password);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      setState(() {
        String? valLogin = preferences.getString("namalogin");
        if(valLogin != null || valLogin != ""){
            _loginStatus = LoginStatus.signIn;
          Fluttertoast.showToast(msg: "Berhasil Login!", toastLength: Toast.LENGTH_SHORT);
        }else {
          Fluttertoast.showToast(msg: "Login Gagal!", toastLength: Toast.LENGTH_SHORT);
        }
      });
    }
  }

//  void cekStatusRunning() async{
//    await getPref();
//    final response = await http.get(ApiService.baseStatusRunning+tokenStatus);
//    final stat = jsonDecode(response.body);
//    setState(() {
//      statusRun = stat['status'];
//    });
//  }

  // savePref(int value, String nip,String tokenlog, String nama, String fotoLogin,String idEselon,String jabatan,String idPNS) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     preferences.setInt("value", value);
  //     preferences.setString("niplogin", nip);
  //     preferences.setString("tokenlogin", tokenlog);
  //     preferences.setString("namalogin", nama);
  //     preferences.setString("fotoLogin", fotoLogin);
  //     preferences.setString("ideselon", idEselon);
  //     preferences.setString("jabatan", jabatan);
  //     preferences.setString("id_pns", idPNS);
  //     preferences.commit();
  //   });
  // }

  // var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      // value = preferences.getString("value");
      // tokenStatus = preferences.getString("tokenlogin");
      _loginStatus = preferences.containsKey("niklogin") ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // await kirimStatusLogout(preferences.getString("id_pns")!);
    setState(() {
      preferences.remove("status");
      preferences.remove("niklogin");
      preferences.remove("tokenlogin");
      preferences.remove("namalogin");
      preferences.remove("namabidang");
      preferences.remove("namaopd");
      preferences.remove("fotoLogin");
      preferences.remove("akseslevel");
      preferences.remove("idformasi");
      preferences.remove("userid");
      preferences.commit();
      // ketika signoutnya berhasil login harus notsignout
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  // kirimStatusLogout(String id_pns) async {
  //   Map<String, dynamic> inputMap = {
  //     'id_pns': id_pns,
  //   };
  //   final response = await http.post(Uri.parse(ApiService.baseStatusLogout),
  //     body: inputMap,
  //   );
  //   final data = jsonDecode(response.body);
  //   //int value = data['status'];
  //   String message = data['message'];
  //   if (response.statusCode == 200) {
  //     //jsonku = dataObjs;
  //     return message;
  //   } else{
  //     return message;
  //   }
  // }

  // init state merpakan method yag pertama kali akan dipanggil saat aplikasi di buka
  @override
  void initState() {
    super.initState();
    getPref();
//    cekStatusRunning();
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor colorCustom = MaterialColor(0xFFFF6C37, color);
      switch (_loginStatus) {
        case LoginStatus.notSignIn:// case saat tidak sign in akan masuk ke hal login
          return Scaffold(
              backgroundColor: Colors.white,
              body: Form(
                key: _key,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(left: 24.0, right: 24.0),
                    children: <Widget>[
                      Hero(tag: 'hero', child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 48.0,
                        child: Image.asset('assets/lg.png'),
                      )),
                      SizedBox(height: 48.0),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        autofocus: true,
//                        initialValue: '197305241999032004/197008281997031012',
                        initialValue:'3301060106910005',
                        validator: (e) {
                          if (e!.isEmpty) {
                            return "Pastikan NIK Anda Benar";
                          }
                        },
                        onSaved: (e) => username = e!,
                        decoration: InputDecoration(
                          hintText: 'NIK',
                          contentPadding: EdgeInsets.fromLTRB(
                              20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        enableSuggestions: false,
                        autocorrect: false,
                        autofocus: false,
//                        initialValue: '24-05-1973/28-08-1970',
                        initialValue: '12345678',
                        //'28-08-1970',
                        //obscureText: true,
                        obscureText: _secureText,
                        onSaved: (e) => password = e!,
                        decoration: InputDecoration(
                            hintText: "Password",
                            contentPadding: EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            suffixIcon: IconButton(
                              onPressed: showhide,
                              icon: Icon(_secureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            )),
                      ),
                      SizedBox(height: 24.0),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(30.0),
                          shadowColor: Colors.lightBlueAccent.shade100,
                          elevation: 5.0,
                          color: colorCustom,//Colors.lightBlueAccent,
                          child: MaterialButton(
                            minWidth: 200.0,
                            height: 42.0,
                            onPressed: () async {
                              // Navigator.of(context).pushNamed(HomePage.tag);
                              //Navigator.pushNamed(context, '/haldashboard');
                              //                        Navigator.pushReplacement(context,
                              //                            new MaterialPageRoute(builder: (context) => new HomePage(signIn)));
                              await check();
                            },
                            child: Text('Log In', style: TextStyle(color: Colors
                                .white)),
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text(
                          'Lupa password?',
                          style: TextStyle(color: Colors.black54),
                        ),
                        onPressed: () {
                          Fluttertoast.showToast(msg: "Silahkan hubungi Admin!", toastLength: Toast.LENGTH_SHORT);
                        },
                      )
                    ],
                  ),
                ),
              )
          );
          break;
        case LoginStatus.signIn: // jika sudah login akan masuk ke main menu
          return HomePage(signOut);//(statusRun=="true") ? HomePage(signOut): MaintenancePage();
          break;

//        case statusRun=="true":
//          return MaintenancePage();
//          break;
      }
//    }else{
//      return MaintenancePage();
//    }


//    final logo = Hero(
//      tag: 'hero',
//      child: CircleAvatar(
//        backgroundColor: Colors.transparent,
//        radius: 48.0,
//        child: Image.asset('assets/ekinerja2020.png'),
//      ),
//    );
  }
}
