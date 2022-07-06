import 'package:kertas/service/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      color: Colors.black12,
      height: double.maxFinite,
      child: new Stack(
        //alignment:new Alignment(x, y)
        children: <Widget>[
          // new Positioned(
          //   child: new Center(
          //     child: new Column(
          //       children: <Widget>[
          //         // new Text("2022 \u00a9 Dinas Kominfo Kabupaten Kebumen"),
          //         new Text("All rights reserved"),
          //       ],
          //     ),
          //   )
          // ),
          new Positioned(
            child: new Center(
              child: new Column(
                children: <Widget>[
                  new Image.asset(
                    'assets/kominfo.png',
                    height: 300,
                    width: 250,
                    fit: BoxFit.fitWidth,
                  ),
                  new Text(ApiService.versionBuildSekarang),
                  new Center(
                    child: new RaisedButton(
                      color: Colors.orangeAccent,
                      onPressed: _launchURL,
                      textColor: Colors.white,
                      splashColor: Colors.grey,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: new Text('Manual E-Kertas Android'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          new Positioned(
            child: new Align(
                alignment: FractionalOffset.bottomCenter,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    new Text("All rights reserved"),
                    new Text("\u00a9 2022 Dinas Kominfo Kabupaten Kebumen"),
                    new Text("Develop by Imanaji Hari Sayekti",style: TextStyle(
                      color: Colors.black12,
                      fontFamily: 'Pasifico',
                    ),)
                  ],
                  )
                // new Text("Develop by Imanaji Hari Sayekti",
                //   style: TextStyle(
                //     color: Colors.black12,
                //     fontFamily: 'Pasifico',
                //     // shadows: <Shadow>[
                //     //   Shadow(
                //     //     offset: Offset(0.0, 0.0),
                //     //     blurRadius: 5.0,
                //     //     color: Colors.black12,
                //     //   ),
                //     // ],
                //   )
                // ),
            ),
          )
        ],
      ),
    );
//    return new Center(
//      child: new Column(
//        children: <Widget>[
//          new Text("Develop by Imanaji Hari Sayekti"),
//          new Text("Copyright 2020 Dinas Kominfo Kabupaten Kebumen"),
//          new Text("All rights reserved"),
//          new Positioned(
//            child: new Align(
//                alignment: FractionalOffset.bottomCenter,
//              child: new Text("Version 1.0.b.04082020"),
//            ),
//          )
//        ],
//      ),
////      child: new Text("Develop by Imanaji Hari Sayekti \nCopyright 2022 Dinas Kominfo Kabupaten Kebumen \nAll rights reserved \nVersion 1.0.b.04082020"),
//    );
  }

  _launchURL() async {
    const url = 'https://tukin.kebumenkab.go.id/assets/manualBook/ManualBookE-KinerjaAndroid.pdf';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}