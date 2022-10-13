import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_table/json_table.dart';
import 'package:json_table/src/json_table_column.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BulanIni extends StatefulWidget {
//  final String idpns,tokenver;
  String? tokenlogin;
  BulanIni({Key? key,required this.tokenlogin}) : super(key: key);

  @override
  _BulanIniState createState() => _BulanIniState();
}

class _BulanIniState extends State<BulanIni> {
  ApiService api = new ApiService();


  //DateTime date = new DateTime(now.year, now.month, now.day);

 // final String jsonSample =
 //     '[{}]';
  bool toggle = true;
  List<JsonTableColumn>? columns;
  String? getData;

  // void setJson() async {
  //   await getPref();
  //   DateTime now = new DateTime.now();
  //   api
  //       .laporanInividu(tokenlogin!, now.month.toString(), now.year.toString())
  //       .then((data) {
  //     setState(() {
  //       if (data != null) {
  //         json = data;
  //       } else {
  //         json =
  //             '[{"tgl_kinerja":"Ram","waktu_mengerjakan":"ram@gmail.com","waktu_diakui":23,"status_kinerja":"1990-12-01"}]';
  //       }
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // getPref();

    // setJson();
    //api.laporanInividu(tokenlogin, "03", "2018");
    //json = api.jsonku;
    //json = api.laporanInividu(tokenlogin, "03", "2018");
    columns = [
      JsonTableColumn("tanggal", label: "Tanggal",defaultValue: "Tidak ada Data"),
      JsonTableColumn("lama_menit", label: "Jml Menit",defaultValue: "Tidak ada Data"),
      JsonTableColumn("deskripsi", label: "Deskripsi",defaultValue: "Tidak ada Data"),
//      JsonTableColumn("honor_diakui", label: "Kinerja Diakui", defaultValue: "-"),
//       JsonTableColumn("DOB", label: "Status",defaultValue: "Tidak ada Data"),
    ];
//     columns = [
//       JsonTableColumn("tgl_kinerja", label: "Tanggal"),
//       JsonTableColumn("waktu_mengerjakan", label: "Menit Mengerjakan"),
//       JsonTableColumn("waktu_diakui", label: "Menit Diakui"),
// //      JsonTableColumn("honor_diakui", label: "Kinerja Diakui", defaultValue: "-"),
//       JsonTableColumn("status_kinerja", label: "Status"),
//     ];
  }

  // Future<Null> getPref() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     tokenlogin = preferences.getString("tokenlogin");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
   // var json = jsonDecode(jsonSample);
    DateTime now = new DateTime.now();
    String bulanIni = DateFormat('MM').format(now);
    return FutureBuilder(
        future: api.laporanInividu(bulanIni, now.year.toString()),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Mohon tunggu sebentar..')
              ],
            );
            // return Center(child: Text('Please wait its loading...'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (snapshot.data != null) {
              return Column(
                children: <Widget>[
                  JsonTable(
                    snapshot.data,
                    columns: columns,
                    showColumnToggle: true,
                    allowRowHighlight: true,
                    rowHighlightColor:
                    Colors.yellow[500]?.withOpacity(0.7),
                    onRowSelect: (index, map) {
                      print(index);
                      print(map);
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
              );
            }else{
              return Text("Tidak ada data");
            }

          }
          else return Text("Tidak ada data");
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

//  String getPrettyJSONString(jsonObject) {
//    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//    String jsonString = encoder.convert(json.decode(jsonObject));
//    return jsonString;
//  }

  String formatDOB(value) {
    var dateTime = DateFormat("yyyy-MM-dd").parse(value.toString());
    return DateFormat("d MMM yyyy").format(dateTime);
  }

  String eligibleToVote(value) {
    if (value >= 18) {
      return "Yes";
    } else
      return "No";
  }
}
