import 'package:kertas/model/daftar_aktivitas.dart';
import 'package:kertas/verifikasi/halVerifikasi.dart';
import 'package:kertas/verifikasi/splash/list_tile_splash.dart';
import 'package:kertas/verifikasi/ui/buttons.dart';
import 'package:kertas/verifikasi/ui/icon_button.dart';
import 'package:kertas/verifikasi/ui/tabs.dart';
import 'package:kertas/verifikasi/util/show_functions.dart';
import 'package:flutter/material.dart';
import 'package:kertas/pages/form_screen.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

ApiService api = new ApiService();
final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class SecondFragment extends StatefulWidget {
  @override
  _SecondFragmentState createState() => _SecondFragmentState();
}

class _SecondFragmentState extends State<SecondFragment>{
  late DaftarAktivitas data;
  // late List<DaftarAktivitas> semuaAktivitas;
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  String tokenlistaktivitas="";
  // String userId="";
  _getRequests() async {
    setState(() {});
  }


  @override
  void initState() {
    // TODO: implement initState
    getPref();
    super.initState();
  }

  Future<Null> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      tokenlistaktivitas = preferences.getString("tokenlogin")!;
      // userId = preferences.getString("userid")!;
    });
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // ApiService api = ApiService();
    List<DaftarAktivitas> semuaAktivitas = [];
    return Scaffold(
      key: _scaffoldState,
      body: FutureBuilder<List<DaftarAktivitas>?>(
        future: api.getAllAktivitasById(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            semuaAktivitas = snapshot.data!;
            if (semuaAktivitas.length == 0) {
              return Center(
                child: Text(
                  "Tidak Ada Data",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              );
            } else {
              return ListView.builder(
                itemExtent: 100,
                itemCount: semuaAktivitas.length,
                itemBuilder: (context, index) {
                  DaftarAktivitas aktivitas = semuaAktivitas[index];
                  return Dismissible(
                      key: UniqueKey(),
                      child: InkWell(
                        onTap: () {
                          print("${aktivitas} clicked");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Swipe ke kanan untuk edit / swipe ke kiri untuk delete")));
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
                                    Text(aktivitas.tglPekerjaan!,style: TextStyle(fontSize: 14, color: Colors.black)),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 5)), //atur jarak antar InkWell
                                    InkWell(
//                              child:  Icon(Icons.edit, size: 20,),
                                      child: new Container(
                                        child: Icon(
                                          Icons.edit,
                                          size: 20,
                                        ),
//                                color: Colors.orange[100],
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(10),
//                                           color: Colors.grey[100],
//                                           boxShadow: [
//                                             BoxShadow(
//                                                 color: Colors.greenAccent,
//                                                 spreadRadius: 1),
//                                           ],
//                                         ),
                                        height: 20,
//                                width: 50.0,
//                                height: 50.0,
                                      ),
                                      onTap: () {
                                        //Masukan navigator di sini
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) {
                                              return FormScreen(
                                                daftaraktivitas: aktivitas,
                                                daftarSudahAda: semuaAktivitas,
                                              );
                                            })).then((value) => value?_getRequests():null);
                                      },
                                    ),
                                    InkWell(
                                        child: new Container(
                                          child: Icon(
                                            Icons.arrow_forward_sharp,
                                            size: 20,
                                          ),
                                          height: 10,
//                                width: 50.0,
//                                height: 50.0,
                                        )
                                    )

                                  ],
                                ),
                                title: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                          child: new Text(aktivitas.namaTugasFungsi!,
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
                                          child: new Text(aktivitas.deskripsiPekerjaan!,
                                              style: TextStyle(
                                                  fontSize: 14, color: Colors.black)))
                                      //Text(aktivitas.uraianPekerjaan)
                                    ]),
                                trailing: Column(
                                  children: <Widget>[
//                               InkWell(
// //                              child:  Icon(Icons.edit, size: 20,),
//                                 child: new Container(
//                                   child: Icon(
//                                     Icons.edit,
//                                     size: 20,
//                                   ),
// //                                color: Colors.orange[100],
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                     color: Colors.grey[100],
//                                     boxShadow: [
//                                       BoxShadow(
//                                           color: Colors.lightBlue,
//                                           spreadRadius: 1),
//                                     ],
//                                   ),
//                                   height: 20,
// //                                width: 50.0,
// //                                height: 50.0,
//                                 ),
//                                 onTap: () {
//                                   //Masukan navigator di sini
//                                   Navigator.push(context,
//                                       MaterialPageRoute(builder: (context) {
//                                     return FormScreen(
//                                       daftaraktivitas: aktivitas,
//                                       daftarSudahAda: semuaAktivitas,
//                                     );
//                                   }));
//                                 },
//                               ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 15)),
                                    InkWell(
                                      child: new Container(
                                        child: Icon(
                                          Icons.delete,
                                          size: 20,
                                        ),
//                                color: Colors.orange[100],
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(10),
//                                           color: Colors.grey[100],
//                                           boxShadow: [
//                                             BoxShadow(
//                                                 color: Colors.red, spreadRadius: 1),
//                                           ],
//                                         ),
                                        height: 30,
//                                width: 50.0,
//                                height: 50.0,
                                      ),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Peringatan'),
                                                content: Text(
                                                    'Apakah Anda yakin akan menghapus?'),
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
                                                      //_deleteTask(aktivitas.idSubPekerjaan);
                                                      api.delete(aktivitas.idPekerjaan!,tokenlistaktivitas)
                                                          .then((result) {
                                                        if (result != null) {
                                                          ScaffoldMessenger.of(
                                                              context)
                                                              .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "Hapus data sukses"),
                                                          ));
                                                          setState(() {});
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                              context)
                                                              .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "Hapus data gagal"),
                                                          ));
                                                        }
                                                      });
                                                      Navigator.of(context).pop();
                                                    },
                                                  )
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )/////////////////////////////////////////////////////////////////////////end card
                      ),
                    background: slideRightBackground(),
                    secondaryBackground: slideLeftBackground(),
                    confirmDismiss: (direction) async{
                      setState(() {});
                      if (direction == DismissDirection.endToStart) {
                        bool res = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    "Apakah Anda yakin akan menghapus?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      "Batal",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                        // setState(() {});
                                      // DismissDirection.startToEnd;
                                      Navigator.pop(context, false);
                                      _getRequests();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      "Hapus",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      // TODO: Delete the item from DB etc..
                                      // setState(() {
                                      //   semuaAktivitas.removeAt(index);
                                      // });
                                      // setState(() {
                                      api.delete(aktivitas.idPekerjaan!,tokenlistaktivitas).then((result) {
                                        if (result == "success") {
                                          // Navigator.of(context).pop();
                                          _getRequests();
                                          // _messangerKey.currentState!.showSnackBar(SnackBar(content: Text(result!)));
                                          // ScaffoldMessenger.of(
                                          //     context)
                                          //     .showSnackBar(SnackBar(
                                          //   // content: Text("Hapus data sukses"),
                                          //   content: Text(result!),
                                          // ));
                                          // Navigator.pop(context, false);
                                        } else {
                                          // Navigator.of(context).pop();
                                          _getRequests();
                                          // _messangerKey.currentState!.showSnackBar(SnackBar(content: Text(result!)));
                                          // ScaffoldMessenger.of(
                                          //     context)
                                          //     .showSnackBar(SnackBar(
                                          //   content: Text(result!),
                                          // ));
                                          // Navigator.pop(context, true);
                                        }
                                      });
                                      // });
                                      Navigator.pop(context, true);
                                      _getRequests();
                                    },
                                  ),
                                ],
                              );
                            });
                        if(res == null) {
                          res = false;

                        }

                        return res;
                      } else { //edit
                        // TODO: Navigate to edit page;
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return FormScreen(
                              daftaraktivitas: aktivitas,
                              daftarSudahAda: semuaAktivitas,
                            );
                          })).then((value) => value?_getRequests():null);
                      }

                    },

                    // onDismissed: (direction){
                    //   if(direction == DismissDirection.startToEnd){
                    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Swipe to right")));
                    //   } else if(direction == DismissDirection.endToStart){
                    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Swipe to right")));
                    //     // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Swipe to right")));
                    //   }
                    // },

                  );

                },
              );
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new FormScreen(daftarSudahAda: semuaAktivitas!)),).then((val) => val ? _getRequests() : null),
        tooltip: 'Tambah Aktivitas',
        child: Icon(Icons.add_circle_outline),
      ),
    );
  }
}
