import 'package:flutter/material.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
ApiService api = new ApiService();

class FirstFragment extends StatefulWidget {
  @override
  _FirstFragmentState createState() => _FirstFragmentState();

}
class _FirstFragmentState extends State<FirstFragment>{
  String? tarikanNamaUser="",tarikanNIKUser="", tarikanPangkatUser="", tarikanJabatanUser="", tarikNamaBidang="", tarikanInstansiUser ="";
  String username="", nama="",tokenlogin="";

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

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Center(
      //child: new Text("Hello Fragment 1"),
      child:Column(
            children: <Widget>[
              new Container(
                  padding: new EdgeInsets.all(20.0),
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Text("Nama"),
                          SizedBox(width: 55.0,),
                          new Text(": "),
                          SizedBox(width: 10.0,),
                          Flexible(child: new Text(tarikanNamaUser!))
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Text("NIK"),
                          SizedBox(width: 15.0,),
                          new Text(": "),
                          SizedBox(width: 10.0,),
                          Flexible(child: new Text(tarikanNIKUser!))
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Text("Bidang"),
                          SizedBox(width: 42.0,),
                          new Text(": "),
                          SizedBox(width: 10.0,),
                          Flexible(child: new Text(tarikNamaBidang!))
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Text("Instansi"),
                          SizedBox(width: 44.0,),
                          new Text(": "),
                          SizedBox(width: 10.0,),
                          Flexible(child: new Text(tarikanInstansiUser!))
                        ],
                      )
                    ],
                  )
              ),
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