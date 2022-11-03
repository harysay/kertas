import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kertas/model/daftar_aktivitas.dart';
import 'package:kertas/model/daftar_presensi.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';


ApiService api = new ApiService();
final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class HistoryPresensi extends StatefulWidget{
  // String? idOpd,idUsers;
  // HistoryPresensi({this.idOpd, this.idUsers});
  @override
  _HistoryPresensi createState() => _HistoryPresensi();
  
}
class _HistoryPresensi extends State<HistoryPresensi>{
  String tokenlistaktivitas="";
  String? idOpd,idUsers;
  List<DaftarPresensi> semuaPresensi = [];

  @override
  void initState() {
    // TODO: implement initState
    getPref();
    super.initState();
  }
  convertStringToDateTime(String stringnya){
    DateTime tempDate = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(stringnya); //=> String to DateTime
    String formattedTime = DateFormat.Hms().format(tempDate);
    return formattedTime;
  }

  Future refreshData() async {
    setState(() {});
  }

  Future<Null> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      tokenlistaktivitas = preferences.getString("tokenlogin")!;
      idOpd = preferences.getString("idopd");
      idUsers = preferences.getString("userid");
      // userId = preferences.getString("userid")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldState,
      body: FutureBuilder<List<DaftarPresensi>?>(
        future: api.getAllPresensiById(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            semuaPresensi = snapshot.data!;
            if (semuaPresensi.length == 0) {
              return Center(
                child: Text(
                  "Tidak Ada Data",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              );
            } else {
              return RefreshIndicator(
                  onRefresh: refreshData,
                  child: ListView.builder(
                    itemExtent: 100,
                    itemCount: semuaPresensi.length,
                    itemBuilder: (context, index) {
                      DaftarPresensi aktivitas = semuaPresensi[index];
                      return Dismissible(
                        key: UniqueKey(),
                        child: InkWell(
                            onTap: () {
                              print("${aktivitas} clicked");
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tidak diizinkan mengubah presensi")));
                            },
                            child: Card(
                              child: Row(
                                children: <Widget>[
                                  // Column 1
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [const Color(0xFFFCDDB0), const Color(0xFFFCF8E8)],
                                          tileMode: TileMode.clamp,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      height: double.infinity,
                                      // color: Color(0xFFFCF8E8),//kuning muda
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            getTitle(aktivitas.tipePresensi!),
                                            getSubName(aktivitas.fullDate!),
                                            // getVenue("E-204"),
                                          ],
                                        ),
                                      ),
                                    )

                                  ),
                                  // Column 2
                                  // The Place where I am Stuck//
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: aktivitas.tipePresensi! == "Absen Pagi" ? [const Color(0xFFBCE29E), const Color(0xFFE5EBB2)] : [const Color(0xFFFF8787), const Color(0xFFF8C4B4)] ,
                                          tileMode: TileMode.clamp,
                                        ),
                                        // color: aktivitas.tipePresensi! == "Absen Pagi" ? Colors.greenAccent : Colors.orangeAccent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      height: double.infinity,
                                      // color: aktivitas.tipePresensi! == "Absen Pagi" ? Colors.greenAccent : Colors.orangeAccent,//Colors.blue,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          getStatus("Online"),
                                          getTime(convertStringToDateTime(aktivitas.fullDate!)),
                                        ],
                                      ),
                                    ),
                                  )
                                  // COlumn 2 End
                                ],
                              ),





                              // child: Padding(
                              //   padding: const EdgeInsets.all(5.0),
                              //   child: Container(
                              //     // height: 80, //atur lebar card list
                              //     child: ListTile(
                              //       leading: Column(
                              //         crossAxisAlignment: CrossAxisAlignment.center,
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         children: <Widget>[
                              //           Text(aktivitas.tanggal!,style: TextStyle(fontSize: 14, color: Colors.black)),
                              //           InkWell(
                              //             child: new Container(
                              //               child: Icon(
                              //                 Icons.edit,
                              //                 size: 20,
                              //               ),
                              //               height: 18,
                              //             ),
                              //           ),
                              //           InkWell(
                              //               child: new Container(
                              //                 child: Icon(
                              //                   Icons.arrow_forward_sharp,
                              //                   size: 20,
                              //                 ),
                              //                 height: 10,
                              //               )
                              //           )
                              //         ],
                              //       ),
                              //       title: Row(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: <Widget>[
                              //             Flexible(
                              //                 child: new Text(aktivitas.tipePresensi!,
                              //                     overflow: TextOverflow.fade,
                              //                     maxLines: 2,
                              //                     softWrap: false,
                              //                     style: TextStyle(
                              //                         fontSize: 18, color: Colors.black)))
                              //           ]),
                              //       subtitle: Row(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: <Widget>[
                              //             Flexible(
                              //                 child: new Text(aktivitas.fullDate!,
                              //                     style: TextStyle(
                              //                         fontSize: 14, color: Colors.black)))
                              //             //Text(aktivitas.uraianPekerjaan)
                              //           ]),
                              //       trailing: Column(
                              //         children: <Widget>[
                              //           Padding(
                              //               padding: EdgeInsets.only(
                              //                   bottom: 15)),
                              //           InkWell(
                              //             child: new Container(
                              //               child: Icon(
                              //                 Icons.delete,
                              //                 size: 20,
                              //               ),
                              //               height: 30,
                              //             ),
                              //             onTap: () {
                              //               showDialog(
                              //                   context: context,
                              //                   builder: (BuildContext context) {
                              //                     return AlertDialog(
                              //                       title: Text('Peringatan'),
                              //                       content: Text('Apakah Anda ingin upload?'),
                              //                       actions: <Widget>[
                              //                         TextButton(
                              //                           child: Text('Tidak'),
                              //                           onPressed: () {
                              //                             Navigator.of(context).pop();
                              //                           },
                              //                         ),
                              //                         TextButton(
                              //                           child: Text('Ya'),
                              //                           onPressed: () {
                              //                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload data sukses"),));
                              //                             Navigator.of(context).pop();
                              //                           },
                              //                         )
                              //                       ],
                              //                     );
                              //                   });
                              //             },
                              //           ),
                              //           InkWell(
                              //               child: new Container(
                              //                 child: Icon(
                              //                   Icons.arrow_back_sharp,
                              //                   size: 20,
                              //                 ),
                              //                 height: 10,
                              //               )
                              //           )
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),



                            )/////////////////////////////////////////////////////////////////////////end card
                        ),
                      );
                    },
                  ));
            }

          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  // Get Title Widget
  Widget getTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(style: TextStyle(fontSize: 22, color: Colors.black54),title),
    );
  }

  // Get Subject Name
  Widget getSubName(String subName) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Text(subName),
    );
  }

  // Get Venue Name
  Widget getVenue(String venue) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: Text(venue),
    );
  }

  Widget getStatus(String status) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Text(style: TextStyle(fontSize: 20, color: Colors.white),status),
    );
  }

  // Color getColor(String type) {
  //   if (type == "L") {
  //     return Color(0xff74B1E9);
  //   }
  // }

  Widget getTime(String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Text(
          style: TextStyle(fontSize: 22, color: Colors.black),time),
    );
  }

}