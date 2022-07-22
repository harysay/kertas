/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';
import 'dart:convert';
import 'package:catcher/catcher.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:kertas/verifikasi/player/content.dart';
import 'package:kertas/verifikasi/player/playlist.dart';
import 'package:kertas/verifikasi/splash/list_tile_splash.dart';
import 'package:kertas/verifikasi/ui/buttons.dart';
import 'package:kertas/verifikasi/ui/tabs.dart';
import 'package:kertas/verifikasi/util/show_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kertas/model/daftar_aktivitas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kertas/verifikasi/ui/icon_button.dart';
import 'package:http/http.dart' as http;
import 'package:kertas/response/daftar_aktivitas_response.dart';
// import 'package:catcher/catcher_plugin.dart';

import 'animations.dart';
import 'selection_widgets.dart';
import 'selection.dart';
import 'switcher.dart';

export 'animations.dart';
export 'selection_widgets.dart';
export 'selection.dart';
export 'switcher.dart';

const kPrimaryColor = Color(0xff4995f7);

void main() async {
  Catcher(rootWidget: App());
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
      ),
      home: Scaffold(
        body: App(),
      ),
    ),
  );
}

final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
class App extends StatefulWidget {
  static GlobalKey<NavigatorState>? get navigatorKey => Catcher.navigatorKey;
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return HalVerif(idpns: "",);
  }
}

/// Main app route with song and album list tabs
class HalVerif extends StatefulWidget {
  final String? idpns,tokenver;
  HalVerif({Key? key, @required this.idpns,@required this.tokenver}) : super(key: key);

  @override
  _HalVerifState createState() => _HalVerifState();
}

class _HalVerifState extends State<HalVerif> with TickerProviderStateMixin {
  SelectionController? selectionController;
  TabController? _tabController;
  List<DaftarAktivitas>? semuaAktivitas;
  var loading = false;
  String tokenlogin="";
  ApiService api = new ApiService();
  TextEditingController alasanKembaliCont = new TextEditingController();
  //String tokenlistaktivitas;

  final _tabs = [
    Tab(
      child: Text(
        "Belum Diverifikasi",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
//    Tab(
//      child: Text(
//        "Sudah Verifikasi",
//        style: TextStyle(
//          fontWeight: FontWeight.w600,
//        ),
//      ),
//    ),
  ];

  @override
  void initState() {
    super.initState();
    getPref();
    // Init selection controller
    selectionController = SelectionController<String>(
      loadedAktivitas: [],
      switcher: IntSwitcher(),
      animationController:
      AnimationController(vsync: this, duration: kSelectionDuration),
    ) // Subscribe to tile clicks to update the selection counter in the SelectionAppBar
      ..addListener(() {
        setState(() {});
      })
    // Subscribe to selection status changes
      ..addStatusListener((status) {
        setState(() {});
      });

    _tabController =
        _tabController = TabController(vsync: this, length: _tabs.length);
  }

  Future<Null> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      tokenlogin = preferences.getString("tokenlogin")!;
    });
  }

  DaftarAktivitas getAktivitasById(String idKinerja){
    return semuaAktivitas!.firstWhere((element) => element.idDataKinerja==idKinerja);
  }

  void _handleSetuju() {
    ContentState(idpns: widget.idpns,tokenver: widget.idpns);
    ShowFunctions.showDialog(context,
      title: const Text("Menyetujui"),
      content: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 15.0),
          children: [
            TextSpan(text: "Anda yakin ingin menyetujui"),
            TextSpan(
              text: selectionController!.loadedAktivitas.length == 1
                  ? " 1 saja?"
//              ContentControl.state
//                  .getPlaylist(PlaylistType.global)
//                  .getAktivitasById(selectionController.loadedAktivitas.first.toString())
//                  .namaPekerjaan
                  : " ${selectionController!.loadedAktivitas.length} aktivitas",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: " ?"),
          ],
        ),
      ),
      acceptButton: DialogRaisedButton(
        text: "Setujui",
        onPressed: ()  {
          selectionController!.close();
          selectionController!.loadedAktivitas.forEach((element)async{
           await api.setujuiAktivitas(tokenlogin, element.idDataKinerja!,element.waktuDiakui!,element.tglKinerja!);
           setState(() {

           });
            //setujui(element.idDataKinerja,element.waktuDiakui,element.tglKinerja);
          });
//          Navigator.pop(context, "Berhasil Disetujui!");
//          Navigator.pop(context);
//          Navigator.pop(context, true);
//          Navigator.pop(context, true);
          ShowFunctions.showToast(msg: "Berhasil Disetujui!");
          Navigator.of(context, rootNavigator: true).pop(true);
//          Navigator.pop(_scaffoldState.currentState.context,true);
        },
      ),
      declineButton: DialogRaisedButton.decline(
        text: "Batal",
        onPressed: () {
          selectionController!.close();
//          selectionController.loadedAktivitas.forEach((element)async{
//            setujui(element.idDataKinerja,element.waktuDiakui,element.tglKinerja);
//          });
//          Navigator.pop(context);
//          Navigator.pop(context, true);
//          Navigator.pop(context, true);
//          ShowFunctions.showToast(msg: "Berhasil Disetujui!");
          Navigator.of(context, rootNavigator: true).pop(true);
//          Navigator.pop(_scaffoldState.currentState.context,true);
        },
      )
    );
    this.setState(() {

    });
  }
  void _handleTolak() {
    ShowFunctions.showDialog(context,
        title: const Text("Yakin ingin tolak Aktivitas?"),
        content: TextField(
          controller: alasanKembaliCont,
          autofocus: true,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            //border: InputBorder.none,
            hintText: 'Isikan Alasan Penolakan di Sini',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        acceptButton: DialogRaisedButton(
          text: "Tolak",
          onPressed: () {
            selectionController!.close();
            selectionController!.loadedAktivitas.forEach((element)async{
              await api.kembalikanAktivitas(tokenlogin, element.idDataKinerja!,"Ditolak",alasanKembaliCont.text);
              setState(() {

              });
              //setujui(element.idDataKinerja,element.waktuDiakui,element.tglKinerja);
            });
//            Navigator.pop(context, "Berhasil Disetujui!");
//            Navigator.pop(context);
//            Navigator.pop(context, true);
//            Navigator.pop(context, true);
            ShowFunctions.showToast(msg: "Berhasil Ditolak!");
          Navigator.of(context, rootNavigator: true).pop(true);
//          Navigator.pop(_scaffoldState.currentState.context,true);
          },
        ),
        declineButton: DialogRaisedButton.decline(
          text: "Batal",
          onPressed: () {
            selectionController!.close();
//          selectionController.loadedAktivitas.forEach((element)async{
//            setujui(element.idDataKinerja,element.waktuDiakui,element.tglKinerja);
//          });
//            Navigator.pop(context);
//          Navigator.pop(context, true);
//          ShowFunctions.showToast(msg: "Berhasil Disetujui!");
          Navigator.of(context, rootNavigator: true).pop(true);
//          Navigator.pop(_scaffoldState.currentState.context,true);
          },
        )
    );
    this.setState(() {

    });
    //ContentControl.deleteSongs(selectionController.selectionSet);
//    Scaffold.of(context).showSnackBar(SnackBar(content: Text(selectionController.loadedAktivitas.first.toString())));
    //semuaAktivitas.add(selectionController.selectionSet)

  }
  void _handleKembalikan() {
    ContentState(idpns: widget.idpns,tokenver: widget.idpns);
    ShowFunctions.showDialog(context,
        title: const Text("Pengembalian"),
          content: TextField(
            controller: alasanKembaliCont,
            autofocus: true,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              //border: InputBorder.none,
              hintText: 'Isikan Alasan Pengembalian di Sini',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
//        content: Text.rich(
//          TextSpan(
//            style: const TextStyle(fontSize: 15.0),
//            children: [
//              TextSpan(text: "Anda yakin ingin mengembalikan aktivitas sebanyak"),
//              TextSpan(
//                text: " ${selectionController.loadedAktivitas.length}",
//                style: const TextStyle(fontWeight: FontWeight.w700),
//              ),
//              TextSpan(text: " ?"),
//            ],
//          ),
//        ),
        acceptButton: DialogRaisedButton(
          text: "Kembalikan",
          onPressed: () {
            selectionController!.close();
            selectionController!.loadedAktivitas.forEach((element)async{
              await api.kembalikanAktivitas(tokenlogin, element.idDataKinerja!,"Dikembalikan",alasanKembaliCont.text);
              setState(() {

              });
              //setujui(element.idDataKinerja,element.waktuDiakui,element.tglKinerja);
            });
//            Navigator.pop(context, "Berhasil Disetujui!");
//            Navigator.pop(context);
//            Navigator.pop(context, true);
//            Navigator.pop(context, true);
            ShowFunctions.showToast(msg: "Berhasil Dikembalikan!");
          Navigator.of(context, rootNavigator: true).pop(true);
//          Navigator.pop(_scaffoldState.currentState.context,true);
          },
        ),
        declineButton: DialogRaisedButton.decline(
          text: "Batal",
          onPressed: () {
            selectionController!.close();
//          selectionController.loadedAktivitas.forEach((element)async{
//            setujui(element.idDataKinerja,element.waktuDiakui,element.tglKinerja);
//          });
//            Navigator.pop(context);
//          Navigator.pop(context, true);
//          ShowFunctions.showToast(msg: "Berhasil Disetujui!");
          Navigator.of(context, rootNavigator: true).pop(true);
//          Navigator.pop(_scaffoldState.currentState.context,true);
          },
        )
    );
    this.setState(() {

    });
    //ContentControl.deleteSongs(selectionController.selectionSet);
//    Scaffold.of(context).showSnackBar(SnackBar(content: Text(selectionController.loadedAktivitas.first.toString())));
    //semuaAktivitas.add(selectionController.selectionSet)

  }

  @override
  void dispose() {
    selectionController!.dispose();
    super.dispose();
  }

  Future<bool> _handlePop(BuildContext context) async {
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop();
      return Future.value(false);
    } else if (selectionController!.inSelection) {
      selectionController!.close();
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final baseAnimation = CurvedAnimation(
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
      parent: selectionController!.animationController,
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.0),
        child: SelectionAppBar(
          // Creating our selection AppBar
          //automaticallyImplyLeading: true,
          titleSpacing: 0.0,
          elevation: 0.0,
          elevationSelection: 2.0,
          selectionController: selectionController!,
          actions: [
//            IconButton(
//              icon: const Icon(Icons.search),
//              onPressed: () {},
//            ),
//            IconButton(
//              icon: const Icon(Icons.sort),
//              onPressed: () {},
//            ),
          ],
          actionsSelection: [
            SizedBox.fromSize(
                size: const Size(kSMMIconButtonSize, kSMMIconButtonSize)),
            SMMIconButton(
              color: Theme.of(context).colorScheme.onSurface,
              icon: const Icon(Icons.backspace,color: Colors.red,size: 27),
              onPressed: _handleTolak,
            ),
            SMMIconButton(
              color: Theme.of(context).colorScheme.onSurface,
              icon: const Icon(Icons.replay,size: 27),
              onPressed: _handleKembalikan,
            ),
            SMMIconButton(
              color: Theme.of(context).colorScheme.onSurface,
              icon: const Icon(Icons.playlist_add_check,color: Colors.lightGreenAccent,size: 34,),
              onPressed: _handleSetuju,
            )
          ],
          title: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              "Pilih Aktivitas",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          titleSelection: Transform.translate(
            offset: const Offset(0, -1.1),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 4.1),
              child: CountSwitcher(
                // Not letting to go less 1 to not play animation from 1 to 0
                childKey: ValueKey(selectionController!.loadedAktivitas.length > 0
                    ? selectionController!.loadedAktivitas.length
                    :1),
                valueIncreased: selectionController!.lengthIncreased,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    (selectionController!.loadedAktivitas.length > 0
                        ? selectionController!.loadedAktivitas.length
                        : 1)
                        .toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) => WillPopScope(
          onWillPop: () => _handlePop(context),
          child: Stack(
            children: <Widget>[
              ScrollConfiguration(behavior: SMMScrollBehaviorGlowless(),
                child: AnimatedBuilder(
                  animation: baseAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    // Don't let user to switch tab  by the swipe gesture when in selection
                    physics: selectionController!.inSelection
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    children: <Widget>[
                      //AktivitasListTab(selectionController: selectionController,listAktivitas: semuaAktivitas),
                      AktivitasListTab(selectionController: selectionController!,idpnsget: widget.idpns,tokenlog: widget.tokenver),
//                      Center(child: Text("Aktivitas yang sudah diverifikasi")),
                    ],
                  ),
                  builder: (BuildContext context, Widget? child) => Padding(
                    padding: EdgeInsets.only(
                      // Offsetting the list back to top
                        top: 44.0 * (1 - baseAnimation.value)),
                    child: child,
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: selectionController!.inSelection,
                child: FadeTransition(
                  opacity: ReverseAnimation(baseAnimation),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashFactory: ListTileInkRipple.splashFactory,
                    ),
                    child: Material(
                      elevation: 2.0,
                      color: Theme.of(context).appBarTheme.color,
                      child: SMMTabBar(
                        controller: _tabController,
                        indicatorWeight: 5.0,
                        indicator: BoxDecoration(
                          // color: Theme.of(context).textTheme.headline6.color,
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: const Radius.circular(3.0),
                            topRight: const Radius.circular(3.0),
                          ),
                        ),
                        labelColor: Theme.of(context).textTheme.headline6!.color,
                        indicatorSize: TabBarIndicatorSize.label,
                        unselectedLabelColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(
                            fontSize: 15.0, fontWeight: FontWeight.w900),
                        tabs: _tabs,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AktivitasListTab extends StatefulWidget {
  AktivitasListTab({
    Key? key,
    required this.selectionController,this.idpnsget,this.tokenlog
  }) : super(key: key);

  final SelectionController selectionController;
  String? idpnsget,tokenlog;

  @override
  _AktivitasListTabState createState() => _AktivitasListTabState();
}

class _AktivitasListTabState extends State<AktivitasListTab>
    with AutomaticKeepAliveClientMixin<AktivitasListTab> {
  // This mixin doesn't allow widget to redraw

  @override
  bool get wantKeepAlive => true;
  ScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    super.build(context);
//    final songs = ContentControl.songs;
    ApiService api = ApiService();
    List<DaftarAktivitas> semuaAktivitas;

    return FutureBuilder(
      future: api.getAllActivityVer(widget.tokenlog!, widget.idpnsget!),
      builder: (BuildContext context, AsyncSnapshot<List<DaftarAktivitas>?> snapshot){
        semuaAktivitas = snapshot.data!;
        if((snapshot.hasData)){
          if (semuaAktivitas.length == 0){
            return Center(
              child: Text(
                "Tidak Ada Data",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }else{
            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 34.0, top: 4.0),
              itemCount: semuaAktivitas.length,
              itemBuilder: (context, index) {
                return SelectableActivityTile(
                  listAktivitas: semuaAktivitas[index],
                  selectionController: widget.selectionController,
                  // Specify object key that can be changed to re-render song tile
                  key: ValueKey(index + widget.selectionController.switcher.value),
                  selected: widget.selectionController.loadedAktivitas.contains(semuaAktivitas[index].idDataKinerja),
                  onTap: () {},
                );
              },
            );
          }
        }
        return Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

class SMMScrollBehaviorGlowless extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}