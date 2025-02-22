import 'dart:convert';
import 'package:kertas/pages/maintenancePage.dart';
import 'package:flutter/material.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:http/http.dart' as http;
import 'package:double_back_to_close/double_back_to_close.dart';

import 'UpdateApp.dart';
import 'login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyApp createState() => new _MyApp();
}

class _MyApp extends State<MyApp> {
  String? statusRun="1",tokenStatus;
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

  @override
  void initState() {
    super.initState();
    cekStatusRunning();
  }

  void cekStatusRunning() async{
    ApiService statusRuning = new ApiService();
    final response = await http.get(Uri.parse(statusRuning.baseUrl+"app/status"));
    final stat = jsonDecode(response.body);
    setState(() {
      statusRun = stat['status'];
    });
  }


  @override
  Widget build(BuildContext context) {
    MaterialColor colorCustom;
    if(statusRun=="1"){
      colorCustom = MaterialColor(0xFF007bff, color);
      return MaterialApp(
        builder: (context,widget) => Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => UpdateApp(
                child: widget!,
              )
          ),
        ),
        title: 'E-Kertas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: TextTheme(
            bodyText1: TextStyle(
                fontSize: 18,
                fontFamily: 'BreeSerif',
                height: 1.5
            ),
            bodyText2: TextStyle(
              fontSize: 16,
              fontFamily: 'Nunito',
                height: 1.5
            ),
            subtitle1: TextStyle(
              fontSize: 14,
              fontFamily: 'Nunito',
              // fontFamily: 'Pasifico',
            )
          ).apply(
            bodyColor: Colors.orange,
            displayColor: Colors.blue,
          )
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        // theme: ThemeData(
        //   primarySwatch: colorCustom,
        //   fontFamily: 'Nunito',
        //   textTheme: TextTheme(
        //     headline2: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //     titleSmall: TextStyle(fontSize: 20.0,
        //         fontStyle: FontStyle.italic,
        //         fontWeight: FontWeight.bold,
        //         decoration: TextDecoration.underline),
        //     bodyText1: TextStyle(fontSize: 18.0, fontFamily: 'Hind', height: 1.5),
        //   ),
        // ),
        home: DoubleBack(
          message:"Tekan sekali lagi untuk keluar",
          child: LoginPage(),
        ),
//        home: LoginPage(),
//        routes: widget.routes,
      );
    }else{
      colorCustom = MaterialColor(0xFF007bff, color);
      return MaterialApp(
          title: 'E-Kertas',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              brightness: Brightness.light,
              textTheme: TextTheme(
                  bodyText1: TextStyle(
                      fontSize: 18,
                      fontFamily: 'BreeSerif',
                      height: 1.5
                  ),
                  bodyText2: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Nunito',
                      height: 1.5
                  ),
                  subtitle1: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    // fontFamily: 'Pasifico',
                  )
              ).apply(
                bodyColor: Colors.orange,
                displayColor: Colors.blue,
              )
          ),
          home: DoubleBack(
            message:"Tekan sekali lagi untuk keluar",
            child: MaintenancePage(),
          )
//        home: MaintenancePage(),//LoginPage(),
//        routes: widget.routes,
      );
    }

  }
}
