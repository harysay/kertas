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
  String tokenlistaktivitas="";
  _getRequests() async {
    // setState(() {});
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
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // ApiService api = ApiService();
    late List<DaftarAktivitas> semuaAktivitas;
    return Scaffold(
      key: _scaffoldState,
      body: FutureBuilder<List<DaftarAktivitas>?>(
        future: api.getAllKontak(tokenlistaktivitas),
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
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        // height: 80, //atur lebar card list
                        child: ListTile(
                          leading: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(aktivitas.tglKinerja!,style: TextStyle(fontSize: 14, color: Colors.black)),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 5)),
                              InkWell(
                                child: new Container(
                                  child: Icon(
                                    Icons.delete,
                                    size: 20,
                                  ),
//                                color: Colors.orange[100],
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[100],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.red, spreadRadius: 1),
                                    ],
                                  ),
                                  height: 20,
//                                width: 50.0,
//                                height: 50.0,
                                ),
                                onTap: () {
//                          _showModalAlert(
//                              'Peringatan',
//                              'Apakah task ini akan di hapus?',
//                              aktivitas.idSubPekerjaan
//                          );
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Peringatan'),
                                          content: Text(
                                              'Apakah Anda yakin akan menghapus?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('No'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                //_deleteTask(aktivitas.idSubPekerjaan);
                                                api
                                                    .delete(
                                                    aktivitas
                                                        .idDataKinerja!,
                                                    tokenlistaktivitas!)
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
                          title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                    child: new Text(
                                        aktivitas.namaPekerjaan! +
                                            " (" +
                                            aktivitas.standarWaktu! +
                                            ")",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black)))
                              ]),
                          subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                    child: new Text(
                                        aktivitas.uraianPekerjaan! +
                                            " (" +
                                            aktivitas.waktuMengerjakan! +
                                            ")",
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
                                      bottom: 25)), //atur jarak antar InkWell
                              InkWell(
//                              child:  Icon(Icons.edit, size: 20,),
                                child: new Container(
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                  ),
//                                color: Colors.orange[100],
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[100],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.lightBlue,
                                          spreadRadius: 1),
                                    ],
                                  ),
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
                                      }));
                                },
                              ),
                            ],
                          ),
                        ),
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Row(
//                      children: <Widget>[
//                        Text(aktivitas. tglKinerja),
//
//                        Text(
//                            aktivitas.namaPekerjaan + " " + aktivitas.waktuMengerjakan),
//                        Spacer(),
//                        Text(aktivitas.uraianPekerjaan),
//                      ],
//                    ),
//                    SizedBox(
//                      height: 10,
//                    ),
//                    Row(
//                      children: <Widget>[
//                        Spacer(),
//                        RaisedButton(
//                          child: Text("Ubah",
//                              style: TextStyle(color: Colors.white)),
//                          color: Colors.orange[400],
//                          onPressed: () {
//                            // panggil FormScreen dengan parameter
//                          },
//                        ),
//                        SizedBox(
//                          width: 5,
//                        ),
//                        RaisedButton(
//                          child: Text("Hapus",
//                              style: TextStyle(color: Colors.white)),
//                          color: Colors.orange[400],
//                          onPressed: () {
//                            // panggil endpoint hapus
//                          },
//                        ),
//                      ],
//                    ),
//                  ],
//                ),
                      ),
                    ),
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
        onPressed: () => Navigator.of(context)
            .push(
              new MaterialPageRoute(
                  builder: (_) =>
                      new FormScreen(daftarSudahAda: semuaAktivitas!)),
            )
            .then((val) => val ? _getRequests() : null),
        tooltip: 'Tambah Aktivitas',
        child: Icon(Icons.add_circle_outline),
      ),
    );
  }
}

// class AktivitasListTab extends StatefulWidget {
//   AktivitasListTab(
//       {Key? key,
//       required this.selectionController,
//       required this.idpnsget,
//       required this.tokenlog})
//       : super(key: key);
//   final SelectionController selectionController;
//   String idpnsget, tokenlog;
//
//   @override
//   _AktivitasListTabState createState() => _AktivitasListTabState();
// }
//
// class _AktivitasListTabState extends State<AktivitasListTab>
//     with AutomaticKeepAliveClientMixin<AktivitasListTab> {
//   // This mixin doesn't allow widget to redraw
//
//   @override
//   bool get wantKeepAlive => true;
//   ScrollController? _scrollController;
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
// //    final songs = ContentControl.songs;
//     ApiService api = ApiService();
//     List<DaftarAktivitas> semuaAktivitas;
//
//     return FutureBuilder<List<DaftarAktivitas>?>(
//       future: api.getAllKontak(widget.tokenlog),
//       builder: (BuildContext context,
//           AsyncSnapshot<List<DaftarAktivitas>?> snapshot) {
//         semuaAktivitas = snapshot.data!;
//         if ((snapshot.hasData)) {
//           if (semuaAktivitas.length == 0) {
//             return Center(
//               child: Text(
//                 "Tidak Ada Data",
//                 style: Theme.of(context).textTheme.subtitle1,
//               ),
//             );
//           } else {
//             return ListView.builder(
//               itemCount: semuaAktivitas.length,
//               itemBuilder: (context, index) {
//                 DaftarAktivitas aktivitas = semuaAktivitas[index];
//                 return Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: Container(
//                       //height: 80, //atur lebar card list
//                       child: ListTile(
//                         leading: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Text(aktivitas.tglKinerja!,
//                                 style: TextStyle(
//                                     fontSize: 14, color: Colors.black))
//                           ],
//                         ),
//                         title: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Flexible(
//                                   child: new Text(
//                                       aktivitas.namaPekerjaan! +
//                                           " (" +
//                                           aktivitas.standarWaktu! +
//                                           ")",
//                                       style: TextStyle(
//                                           fontSize: 18, color: Colors.black)))
// //                  Text(aktivitas.namaPekerjaan),Text(" ("+aktivitas.standarWaktu+")",style: TextStyle(fontSize: 11, color: Colors.black))
//                             ]),
//                         subtitle: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Flexible(
//                                   child: new Text(
//                                       aktivitas.uraianPekerjaan! +
//                                           " (" +
//                                           aktivitas.waktuMengerjakan! +
//                                           ")",
//                                       style: TextStyle(
//                                           fontSize: 14, color: Colors.black)))
//                               //Text(aktivitas.uraianPekerjaan)
//                             ]),
//                         trailing: Column(
//                           children: <Widget>[
//                             InkWell(
// //                              child:  Icon(Icons.edit, size: 20,),
//                               child: new Container(
//                                 child: Icon(
//                                   Icons.edit,
//                                   size: 20,
//                                 ),
// //                                color: Colors.orange[100],
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.grey[100],
//                                   boxShadow: [
//                                     BoxShadow(
//                                         color: Colors.lightBlue,
//                                         spreadRadius: 1),
//                                   ],
//                                 ),
//                                 height: 20,
// //                                width: 50.0,
// //                                height: 50.0,
//                               ),
//                               onTap: () {
//                                 //Masukan navigator di sini
//                                 Navigator.push(context,
//                                     MaterialPageRoute(builder: (context) {
//                                   return FormScreen(
//                                     daftaraktivitas: aktivitas,
//                                     daftarSudahAda: semuaAktivitas,
//                                   );
//                                 }));
//                               },
//                             ),
//                             Padding(
//                                 padding: EdgeInsets.only(
//                                     bottom: 16)), //atur jarak antar InkWell
//                             InkWell(
//                               child: new Container(
//                                 child: Icon(
//                                   Icons.delete,
//                                   size: 20,
//                                 ),
// //                                color: Colors.orange[100],
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.grey[100],
//                                   boxShadow: [
//                                     BoxShadow(
//                                         color: Colors.red, spreadRadius: 1),
//                                   ],
//                                 ),
//                                 height: 20,
// //                                width: 50.0,
// //                                height: 50.0,
//                               ),
//                               onTap: () {
// //                          _showModalAlert(
// //                              'Peringatan',
// //                              'Apakah task ini akan di hapus?',
// //                              aktivitas.idSubPekerjaan
// //                          );
//                                 showDialog(
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return AlertDialog(
//                                         title: Text('Peringatan'),
//                                         content: Text(
//                                             'Apakah Anda yakin akan menghapus?'),
//                                         actions: <Widget>[
//                                           TextButton(
//                                             child: Text('No'),
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                           ),
//                                           TextButton(
//                                             child: Text('Yes'),
//                                             onPressed: () {
//                                               //_deleteTask(aktivitas.idSubPekerjaan);
//                                               api
//                                                   .delete(
//                                                       aktivitas.idDataKinerja!,
//                                                       widget.tokenlog)
//                                                   .then((result) {
//                                                 if (result != null) {
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(SnackBar(
//                                                     content: Text(
//                                                         "Hapus data sukses"),
//                                                   ));
//                                                   setState(() {});
//                                                 } else {
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(SnackBar(
//                                                     content: Text(
//                                                         "Hapus data gagal"),
//                                                   ));
//                                                 }
//                                               });
//                                               Navigator.of(context).pop();
//                                             },
//                                           )
//                                         ],
//                                       );
//                                     });
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
// //                child: Column(
// //                  crossAxisAlignment: CrossAxisAlignment.center,
// //                  mainAxisAlignment: MainAxisAlignment.center,
// //                  children: <Widget>[
// //                    Row(
// //                      children: <Widget>[
// //                        Text(aktivitas. tglKinerja),
// //
// //                        Text(
// //                            aktivitas.namaPekerjaan + " " + aktivitas.waktuMengerjakan),
// //                        Spacer(),
// //                        Text(aktivitas.uraianPekerjaan),
// //                      ],
// //                    ),
// //                    SizedBox(
// //                      height: 10,
// //                    ),
// //                    Row(
// //                      children: <Widget>[
// //                        Spacer(),
// //                        RaisedButton(
// //                          child: Text("Ubah",
// //                              style: TextStyle(color: Colors.white)),
// //                          color: Colors.orange[400],
// //                          onPressed: () {
// //                            // panggil FormScreen dengan parameter
// //                          },
// //                        ),
// //                        SizedBox(
// //                          width: 5,
// //                        ),
// //                        RaisedButton(
// //                          child: Text("Hapus",
// //                              style: TextStyle(color: Colors.white)),
// //                          color: Colors.orange[400],
// //                          onPressed: () {
// //                            // panggil endpoint hapus
// //                          },
// //                        ),
// //                      ],
// //                    ),
// //                  ],
// //                ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         }
//         return Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//   }
// }
