import 'package:flutter/material.dart';
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

    super.initState();
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
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  // height: 80, //atur lebar card list
                                  child: ListTile(
                                    leading: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(aktivitas.tanggal!,style: TextStyle(fontSize: 14, color: Colors.black)),
                                        InkWell(
                                          child: new Container(
                                            child: Icon(
                                              Icons.edit,
                                              size: 20,
                                            ),
                                            height: 18,
                                          ),
                                        ),
                                        InkWell(
                                            child: new Container(
                                              child: Icon(
                                                Icons.arrow_forward_sharp,
                                                size: 20,
                                              ),
                                              height: 10,
                                            )
                                        )
                                      ],
                                    ),
                                    title: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                              child: new Text(aktivitas.tipePresensi!,
                                                  overflow: TextOverflow.fade,
                                                  maxLines: 2,
                                                  softWrap: false,
                                                  style: TextStyle(
                                                      fontSize: 18, color: Colors.black)))
                                        ]),
                                    subtitle: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                              child: new Text(aktivitas.fullDate!,
                                                  style: TextStyle(
                                                      fontSize: 14, color: Colors.black)))
                                          //Text(aktivitas.uraianPekerjaan)
                                        ]),
                                    trailing: Column(
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 15)),
                                        InkWell(
                                          child: new Container(
                                            child: Icon(
                                              Icons.delete,
                                              size: 20,
                                            ),
                                            height: 30,
                                          ),
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Peringatan'),
                                                    content: Text('Apakah Anda ingin upload?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text('Tidak'),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text('Ya'),
                                                        onPressed: () {
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload data sukses"),));
                                                          Navigator.of(context).pop();
                                                        },
                                                      )
                                                    ],
                                                  );
                                                });
                                          },
                                        ),
                                        InkWell(
                                            child: new Container(
                                              child: Icon(
                                                Icons.arrow_back_sharp,
                                                size: 20,
                                              ),
                                              height: 10,
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
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
}