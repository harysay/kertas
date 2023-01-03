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
  convertStringToDateOnly(String stringnya){
    DateTime tempDate = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(stringnya); //=> String to DateTime
    String formattedTime = "${tempDate.day}-${tempDate.month}-${tempDate.year}";
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Daftar Presensi",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<DaftarPresensi>?>(
        future: api.getAllPresensiByIdBulan(),
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
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            getTitle(aktivitas.tipePresensi!),
                                            getSubName(convertStringToDateOnly(aktivitas.fullDate!))
                                            // getSubName(aktivitas.fullDate!),
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
      padding: EdgeInsets.only(bottom: 2.0),
      child: Text(style: TextStyle(fontSize: 22, color: Colors.black54),title),
    );
  }

  // Get Subject Name
  Widget getSubName(String subName) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Text(style: TextStyle(fontSize: 16, color: Colors.black54),subName),
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
      padding: EdgeInsets.only(bottom: 1.0),
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
      padding: EdgeInsets.only(bottom: 5.0),
      child: Text(
          style: TextStyle(fontSize: 22, color: Colors.black),time),
    );
  }

}