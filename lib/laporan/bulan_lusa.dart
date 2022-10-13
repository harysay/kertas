import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_table/json_table.dart';
import 'package:json_table/src/json_table_column.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BulanLusa extends StatefulWidget {
  @override
  _BulanLusaState createState() => _BulanLusaState();
}

class _BulanLusaState extends State<BulanLusa> {
  ApiService api = new ApiService();
  String? tokenlogin;
  var json;
  bool toggle = true;
  List<JsonTableColumn>? columns;
  String? getData;

  void setJson() async{
    await getPref();
    DateTime now = new DateTime.now();
    var bulanLusa = now.month-2;
    var bulanKemarin = now.month-1;
    var tahunIni = now.year;
    if(bulanKemarin.toString()=="0"){
      bulanLusa = 11;
      tahunIni = now.year-1;
    }
    String stringValue = bulanLusa.toString();
    if(stringValue.length==1){
      stringValue="0"+stringValue;
    }
    api.laporanInividu(stringValue, tahunIni.toString()).then((data){
      setState(() {
        json = data;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setJson();
    columns = [
      JsonTableColumn("tanggal", label: "Tanggal",defaultValue: "Tidak ada Data"),
      JsonTableColumn("lama_menit", label: "Jml Menit",defaultValue: "Tidak ada Data"),
      JsonTableColumn("deskripsi", label: "Deskripsi",defaultValue: "Tidak ada Data"),
    ];
  }

  Future<Null> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      tokenlogin = preferences.getString("tokenlogin");
    });
  }

  @override
  Widget build(BuildContext context) {
//    var json = jsonDecode(jsonSample);
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: json == null ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Mohon tunggu sebentar..')
            ],
          ),
        ) : Column(
          children: <Widget>[
            JsonTable(
              json,
              columns: columns,
              showColumnToggle: true,
              allowRowHighlight: true,
              rowHighlightColor: Colors.yellow[500]?.withOpacity(0.7),
              tableCellBuilder: (value) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.5))),
                  child: Text(
                    value,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[900]),
                  ),
                );
              },
            ),
            SizedBox(
              height: 16.0,
            ),
//            Text(
//              getPrettyJSONString(jsonSample),
//              style: TextStyle(fontSize: 13.0),
//            ),
          ],
        ),
      ),
    );
  }
}
