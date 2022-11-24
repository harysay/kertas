import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:kertas/model/daftar_presensi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

//import 'package:ekinerja2020/model/daftar_pekerjaan.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kertas/model/daftar_aktivitas.dart';
import 'package:kertas/model/data_tusi.dart';
import 'package:kertas/response/daftarTusiResponse.dart';
import 'package:kertas/service/ApiService.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:kertas/model/localization_dropdown_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';  //for date format
import 'package:intl/date_symbol_data_local.dart';  //for date locale
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../common/card_picture.dart';
import '../common/take_photo.dart';
import '../service/dio_upload_service.dart';
import '../service/http_upload_service.dart';

final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class FormPresensi extends StatefulWidget {
  // List<DaftarAktivitas>? daftarSudahAda;
  String masukAtauPulang;
  // DaftarAktivitas? daftaraktivitas;
  FormPresensi({required this.masukAtauPulang});

  @override
  _FormPresensiState createState() => _FormPresensiState();
}

class _FormPresensiState extends State<FormPresensi> {
  // Position? _currentPosition;
  // String? _currentAddress;
  late CameraDescription _cameraDescription;
  var dataJson,_daftarPekerjaan,_daftarSubPekerjaan;
  //List<DaftarPekerjaan> semuaPekerjaan;
  String _date = "Belum diset";
  String _timeMulai = "Belum diset";
  String _timeBatasCheckIn = "08:00";

  late String tokenlistaktivitas,idFormasi;
  String idOpd = "";
  String idUser = "";
  TimeOfDay timeLimit = TimeOfDay(hour: 15, minute: 30);
  TimeOfDay startTime = TimeOfDay(hour: 7, minute: 30);
  TimeOfDay endTime = TimeOfDay(hour: 23, minute: 59);
  String? pekerjaanDefaultEdit;
  List? statesList = [];
  List<DataTusi>? dat = [];
  String? _state;
  ApiService api = new ApiService();
  TextEditingController ctrlIdSubPekerjaan = new TextEditingController();
  TextEditingController ctrlUraianPekerjaan = new TextEditingController();

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  var loading = false;
  String? gambarPath="";
  _getCamera() async {
    // await getPref();
    // setState(() {
    //
    // });
    // final getDaftarTusi = await http.get(Uri.parse(api.baseDaftarPekerjaan+tokenlistaktivitas!));
    // if(getDaftarTusi.statusCode == 200){
    //   final jsonResponse = json.decode(getDaftarTusi.body);
    //
    //   Localization places = new Localization.fromJson(jsonResponse);
    //
    //
    // }
    // setState(() {
      // if(getAllDataTusi() != null){
      //   loading = true;
      //   dat = getAllDataTusi();
      //   statesList = dat;
      // }
      // if (this.widget.daftaraktivitas != null) { //ngecek ada isinya nggak klo ada isinya berarti edit
      //   _date = this.widget.daftaraktivitas!.tglPekerjaan!;
      //   _timeMulai = this.widget.daftaraktivitas!.jamMulai!;
      //   _timeBatasCheckIn = this.widget.daftaraktivitas!.jamSelesai!;
      //   pekerjaanDefaultEdit = this.widget.daftaraktivitas!.namaTugasFungsi;
      //   _state = this.widget.daftaraktivitas!.idTusi;
      //
      //   //gambarPath = (this.widget.daftaraktivitas!.dataDukung!.contains("http") ? _fileFromImageUrl().toString():this.widget.daftaraktivitas!.dataDukung) as String?;
      //   await _fileFromImageUrl();
      //   // getIdSubPekerjaanValue = this.widget.daftaraktivitas!.idSubPekerjaan;
      //   ctrlUraianPekerjaan.text = this.widget.daftaraktivitas!.deskripsiPekerjaan!;
      //   //ctrlIdSubPekerjaan.text = this.widget.daftaraktivitas.idSubPekerjaan;
      // }
      availableCameras().then((cameras) {
        final camera = cameras
            .where((camera) => camera.lensDirection == CameraLensDirection.back)
            .toList()
            .first;
        setState(() {
          _cameraDescription = camera;
        });
      }).catchError((err) {
        print(err);
      });
      // provincesList = places.subpekerjaan;
      // if (this.widget.daftaraktivitas != null) {
      //   tempList = provincesList;
      // }
      // loading = false;
    // });

  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if(appDir.existsSync()){
      appDir.deleteSync(recursive: true);
    }
  }

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  // Future<String> _fileFromImageUrl() async {
  //   final response = await http.get(Uri.parse(this.widget.daftaraktivitas!.dataDukung!));
  //   final documentDirectory = await getTemporaryDirectory();
  //   final file = File(join(documentDirectory.path, getRandomString(10)+'.jpg'));
  //   file.writeAsBytesSync(response.bodyBytes);
  //   file.path;
  //   gambarPath = file.path;
  //   print('jenengfile:'+gambarPath!);
  //   return file.path;
  // }
  
  @override
  void initState() {
    //_states = List.from(_states)..addAll(api_pekerjaan.getAllPekerjaan());
    //DaftarPekerjaan pekerjaan = semuaPekerjaan[]
    //List<String> getPekerjaan() => _list.map((map) => DaftarPekerjaan.fromJson(map)).map(item) =>ite
    //_fetchData();
    // _getCurrentLocation();
    getPref();
    getLocation();


    // statesList = api.getAllDataTusi(tokenlistaktivitas).then((value) => null) as List?;
    _getCamera();
    //Jika ada lemparan dari second_fragment (Edit) maka dilakukan berikut

    super.initState();
  }

  Future<void> presentAlert(BuildContext context,
      {String title = '', String message = '', Function()? ok}) {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('$title'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text('$message'),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  // style: greenText,
                ),
                onPressed: ok != null ? ok : Navigator.of(context).pop,
              ),
            ],
          );
        });
  }

  void presentLoader(BuildContext context,
      {String text = 'Tunggu...',
        bool barrierDismissible = false,
        bool willPop = true}) {
    showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (c) {
          return WillPopScope(
            onWillPop: () async {
              return willPop;
            },
            child: AlertDialog(
              content: Container(
                child: Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      text,
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<Null> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      tokenlistaktivitas = preferences.getString("tokenlogin")!;
      idFormasi = preferences.getString("idformasi")!;
      idOpd = preferences.getString("idopd")!;
      idUser = preferences.getString("userid")!;
      // idTusi = preferences.getString("idformasi")!;
      // deskripsi = preferences.getString("idformasi")!;
      // tanggal = preferences.getString("idformasi")!;
      // waktuMulai = preferences.getString("idformasi")!;
      // waktuSelesai = preferences.getString("idformasi")!;

    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.masukAtauPulang == "masuk" ? "Form Masuk" : "Form Pulang",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child:loading ? Center(child: CircularProgressIndicator())
            : Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(15.0),
            children: <Widget>[
              Column(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.greenAccent)))
                        ),
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              theme: DatePickerTheme(
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true,
                              minTime: DateTime(2019, 1, 1),
                              maxTime: DateTime(2025, 12, 31), onConfirm: (date) {
                                print('confirm $date');
                                _date = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
                                setState(() {});
                              }, currentTime: DateTime.now(), locale: LocaleType.en);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Tanggal aktivitas",style: Theme.of(context).textTheme.caption),
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.date_range,
                                              size: 18.0,
                                            ),
                                            Text(
                                              " $_date",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),

                                ],
                              ),
                              Text("Ubah",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        // color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 18.0, right: 18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Text(servicestatus? "GPS is Enabled": "GPS is disabled."),
                          // Text(haspermission? "GPS is Enabled": "GPS is disabled."),

                          Text("Longitude: $long", style:TextStyle(fontSize: 20)),
                          Text("Latitude: $lat", style: TextStyle(fontSize: 20),),
                          // long!=null? Text('Longitude: $long', style:TextStyle(fontSize: 20)) : Text('Menunggu Koordinat Long'),
                          // lat!=null? Text('Latitude: $lat', style:TextStyle(fontSize: 20)) : Text('Menunggu Koordinat Lat'),

                          // _currentPosition!=null? Text('Latitude: ${_currentPosition?.latitude}') : Text('Menunggu Koordinat Lat'),
                          // _currentPosition!=null? Text('Longitude: ${_currentPosition?.longitude}') : Text('Menunggu Koordinat Long'),
                          // _currentAddress!=null? Text('Alamat: ${_currentAddress}') : Text('Menunggu Alamat'),
                          // if (_currentPosition != null) Text(
                          //     "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"
                          // ),
                          // Text("LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"),
                          // FlatButton(
                          //   child: Text("Get location"),
                          //   onPressed: () {
                          //     _getCurrentLocation();
                          //   },
                          // ),
                        ],
                      ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  Column(
                    children: [
                      Text('Potret dokumen pendukung', style: TextStyle(fontSize: 17.0)),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        height: 400,
                        child: gambarPath == "" ? Card(
                            elevation: 3,
                            child: InkWell(
                              onTap: () async {
                                final String? imagePath =
                                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TakePhoto(camera: _cameraDescription,
                                    ))).then((value) {
                                      gambarPath=(value)['gambarku'];
                                });
                                print('imagepath: $imagePath');
                                if (gambarPath != null) {
                                  setState(() {
                                    print('imagepath: $imagePath');
                                    // _images.add(imagePath);
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 25),
                                width: size.width * .70,
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attach Picture',
                                      style: TextStyle(fontSize: 17.0, color: Colors.grey[600]),
                                    ),
                                    Icon(
                                      Icons.photo_camera,
                                      color: Colors.indigo[400],
                                    )
                                  ],
                                ),
                              ),
                            )
                        ):Card(
                          child: Container(
                            height: 300,
                            padding: EdgeInsets.all(10.0),
                            width: size.width * .70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(File(gambarPath as String))
                                  // image: gambarPath!.contains("http") ? FileImage(File(_fileFromImageUrl() as String)):FileImage(File(gambarPath as String))
                              ),
                            ),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.redAccent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(3.0, 3.0),
                                          blurRadius: 2.0,
                                        )
                                      ]
                                  ),
                                  child: IconButton(onPressed: (){
                                    print('icon press');
                                    setState(() {
                                      gambarPath = "";
                                    });

                                  }, icon: Icon(Icons.delete, color: Colors.white)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                      // color: Colors.indigo,
                                        gradient: LinearGradient(colors: [
                                          Colors.indigo,
                                          Colors.indigo.shade800
                                        ]),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(3.0))),
                                    child: RawMaterialButton(
                                      padding: EdgeInsets.symmetric(vertical: 12.0),
                                      onPressed: () async {
                                        if (validateInput()) {
                                          DaftarPresensi dataIn = new DaftarPresensi(
                                            idOpd: idOpd,
                                            idUsers: idUser,
                                            latitude: lat,
                                            longitude: long,
                                            // data_dukung: gambarPath,
                                            tanggal: _date);
                                          api.uploadPresensi(dataIn,gambarPath!, tokenlistaktivitas!).then((result) {
                                            if (result=="success") {
                                              _deleteCacheDir();
                                              Navigator.pop(_scaffoldState.currentState!.context, true);
                                              // Navigator.pop(ScaffoldMessenger.of(context).context, true);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text(result),
                                              ));
                                            }
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text("Data belum lengkap"),
                                          ));
                                        }
                                      },
                                      child: Center(
                                          child: Text("Presensi",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    )),
                              )
                            ],
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        )
      )
    );
  }

  // _getCurrentLocation() {
  //   loading = true!;
  //   Geolocator
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
  //       .then((Position position) {
  //     setState(() {
  //       _currentPosition = position;
  //       _getAddressFromLatLng(_currentPosition!.latitude.toDouble(),_currentPosition!.longitude.toDouble());
  //     });
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }
  //
  // _getAddressFromLatLng(double lat, double long) async {
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
  //
  //     Placemark place = placemarks[0];
  //
  //     setState(() {
  //       _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // checkGps() async {
  //   servicestatus = await Geolocator.isLocationServiceEnabled();
  //   if(servicestatus){
  //     permission = await Geolocator.checkPermission();
  //
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         print('Location permissions are denied');
  //       }else if(permission == LocationPermission.deniedForever){
  //         print("'Location permissions are permanently denied");
  //       }else{
  //         haspermission = true;
  //       }
  //     }else{
  //       haspermission = true;
  //     }
  //
  //     if(haspermission){
  //       setState(() {
  //         //refresh the UI
  //       });
  //
  //       getLocation();
  //     }
  //   }else{
  //     print("GPS Service is not enabled, turn on GPS location");
  //   }
  //
  //   setState(() {
  //     //refresh the UI
  //   });
  // }

  getLocation() async {
    loading = true!;
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();
    long!=""?loading = false!:loading = true!;
    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }

//  void _onSelectedState(String value) {
//    setState(() {
//      _selectedLGA = "Choose ..";
//      _lgas = ["Choose .."];
//      _selectedState = value;
//      _lgas = List.from(_lgas)..addAll(getLocalByState(value));
//    });
//  }
//
//  getLocalByState(String nampek) => dataJson
//      .map((map) => DaftarPekerjaan.fromJson(map))
//      .where((item) => item.namasubpekerjaan == nampek)
//      .map((item) => item.standarwaktu)
//      .expand((i) => i)
//      .toList();
//
//  void _onSelectedLGA(String value) {
//    setState(() => _selectedLGA = value);
//  }

  bool validateInput() {
    if (_date == "Belum diset" //||
        // ctrlUraianPekerjaan.text == "" ||
       // _timeMulai == ""||
       //  _timeBatasCheckIn == ""
    ) {
      return false;
    } else {
      return true;
    }
  }

//  bool compareJamTanggal(DaftarAktivitas datInput, String tgl, String jamSelesai){
//    for(int i=0; i<=widget.daftarSudahAda.length; i++) {
//      TimeOfDay mulaiInput = TimeOfDay(hour: int.parse(datInput.jamMulai.split(":")[0]),minute: int.parse(datInput.jamMulai.split(":")[1]));
//      TimeOfDay selesaiSudahAda = TimeOfDay(hour: int.parse(widget.daftarSudahAda[i].jamSelesai.split(":")[0]),minute: int.parse(widget.daftarSudahAda[i].jamSelesai.split(":")[1]));
//      double selInput = mulaiInput.hour.toDouble() + (mulaiInput.minute.toDouble() / 60);
//      double selSudahada = selesaiSudahAda.hour.toDouble() +  (selesaiSudahAda.minute.toDouble() / 60);
//      if (datInput.tglKinerja == widget.daftarSudahAda[i].tglKinerja && selInput < selSudahada) {
//        AlertDialog(
//          title: new Text(
//              "Tidak diperbolehkan"),
//          content: new Text(
//              "Anda sudah input kegiatan pada tanggal dan jam tersebut"),
//          actions: <Widget>[
//            // usually buttons at the bottom of the dialog
//            new FlatButton(
//              child: new Text("Tutup"),
//              onPressed: () {
//                Navigator.of(context)
//                    .pop();
//              },
//            ),
//          ],
//        );
//        return false;
//      } else {
//        return true;
//      }
//    }
//  }

}