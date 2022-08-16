import 'dart:convert';

//import 'package:ekinerja2020/model/daftar_pekerjaan.dart';
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

final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class FormScreen extends StatefulWidget {
  List<DaftarAktivitas>? daftarSudahAda;
  DaftarAktivitas? daftaraktivitas;
  FormScreen({this.daftarSudahAda, this.daftaraktivitas});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  Position? _currentPosition;
  String? _currentAddress;
  //DaftarPekerjaan repo = DaftarPekerjaan();
  var dataJson,_daftarPekerjaan,_daftarSubPekerjaan;
  //List<DaftarPekerjaan> semuaPekerjaan;
  String _date = "Belum diset";
  String _timeMulai = "Belum diset";
  String _timeSelesai = "Belum diset";

  late String tokenlistaktivitas,tanggalAkSebelum,jamMulaiSebelum;
  TimeOfDay timeLimit = TimeOfDay(hour: 15, minute: 30);
  TimeOfDay startTime = TimeOfDay(hour: 7, minute: 30);
  TimeOfDay endTime = TimeOfDay(hour: 23, minute: 59);
  //List<String> _states = ["Pilih Pekerjaan"];
  //List<String> _lgas = ["Pilih waktu"];
  //List<String> _subPekerjaan;
  //String _selectedState = "Choose a state";
  //String _selectedLGA = "Choose ..";
  String? pekerjaanDefaultEdit;
  List? statesList = [];
  List<DataTusi>? dat = [];
  // List? provincesList = [];
  // List? tempList = [];
  String? _state;
  // String? getIdSubPekerjaanValue;
  ApiService api = new ApiService();
//  ApiService_pekerjaan api_pekerjaan = new ApiService_pekerjaan();
  //TextEditingController ctrlTanggalAktivitas = new TextEditingController();
  TextEditingController ctrlIdSubPekerjaan = new TextEditingController();
  TextEditingController ctrlUraianPekerjaan = new TextEditingController();

  var loading = false;
  _populateDropdown() async {
    await getPref();
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
    setState(() {
      // if(getAllDataTusi() != null){
      //   loading = true;
      //   dat = getAllDataTusi();
      //   statesList = dat;
      // }
      getAllDataTusi();

      // provincesList = places.subpekerjaan;
      // if (this.widget.daftaraktivitas != null) {
      //   tempList = provincesList;
      // }
      // loading = false;
    });

  }
  
  @override
  void initState() {
    //_states = List.from(_states)..addAll(api_pekerjaan.getAllPekerjaan());
    //DaftarPekerjaan pekerjaan = semuaPekerjaan[]
    //List<String> getPekerjaan() => _list.map((map) => DaftarPekerjaan.fromJson(map)).map(item) =>ite
    //_fetchData();
    _getCurrentLocation();

    getPref();
    // statesList = api.getAllDataTusi(tokenlistaktivitas).then((value) => null) as List?;
    _populateDropdown();
    //Jika ada lemparan dari second_fragment (Edit) maka dilakukan berikut
    if (this.widget.daftaraktivitas != null) { //ngecek ada isinya nggak klo ada isinya berarti edit
      _date = this.widget.daftaraktivitas!.tglPekerjaan!;
      _timeMulai = this.widget.daftaraktivitas!.jamMulai!;
      _timeSelesai = this.widget.daftaraktivitas!.jamSelesai!;
      pekerjaanDefaultEdit = this.widget.daftaraktivitas!.namaTugasFungsi;
      _state = this.widget.daftaraktivitas!.idTusi;
      // getIdSubPekerjaanValue = this.widget.daftaraktivitas!.idSubPekerjaan;
      ctrlUraianPekerjaan.text = this.widget.daftaraktivitas!.deskripsiPekerjaan!;
      //ctrlIdSubPekerjaan.text = this.widget.daftaraktivitas.idSubPekerjaan;
    }
    super.initState();
  }

//   Future<Null> fetchAktivitasSebelumnya()async{
//     setState(() {
//       loading = true;
//     });
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     setState(() {
//       tokenlistaktivitas = preferences.getString("tokenlogin");
//
//     });
//     final response = api.getAllKontak(tokenlistaktivitas!);
//     if(response.statusCode == 200){
//       var tagObjsJson = jsonDecode(response.body)['data'] as List;
//       List<DaftarAktivitas> tagObjs = tagObjsJson.map((tagJson) => DaftarAktivitas.fromJson(tagJson)).toList();
//
//       print(tagObjs);
//
// //      final data = jsonDecode(response.body);
// //      //final _daftarPekerjaan = data['data'];
// //      setState(() {
// //        tanggalAkSebelum = data["data"]["tgl_kinerja"];
// //        jamMulaiSebelum = data["data"]["jam_mulai"];
// //      });
//     }else{
//       Text("error bro");
//     }
//   }

  DaftarTusiResponse tusiRes = new DaftarTusiResponse();
  getAllDataTusi() async {
    await getPref();
    // loading = true;
    //Map<String, dynamic> inputMap = {'DEMO-API-KEY': '$key'};
    final response = await http.get(Uri.parse(api.baseUrl+"tusi/gettusi"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": tokenlistaktivitas
      },
//      body: inputMap,
    );
    tusiRes = DaftarTusiResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      statesList = tusiRes.data;
      loading = false;
      return statesList;
    } else {
      return null;
      loading = false;
    }
  }

  Future<Null> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      tokenlistaktivitas = preferences.getString("tokenlogin")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.daftaraktivitas == null ? "Form Tambah" : "Form Update",
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
                  AbsorbPointer(
                    absorbing: widget.daftaraktivitas == null ? false : true,
                    child: Column(
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
                                                color: widget.daftaraktivitas == null ? Colors.teal : Colors.black12,
                                              ),
                                              Text(
                                                " $_date",
                                                style: TextStyle(
                                                    color: widget.daftaraktivitas == null ? Colors.teal : Colors.black12,
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
                                Text(widget.daftaraktivitas == null ? "  Ubah" : "",
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
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 18.0, right: 18.0),
                    child: new DropdownButton<String>(
                      isExpanded: true,
                      icon: const Icon(Icons.border_color),
                      items: statesList?.map((item) {
                        return new DropdownMenuItem<String>(
                          child: new Text(item.namaTusi),// Text(item.standarWaktu),
                          value: item.idTusi.toString(),
                        );
                      }).toList(),
                      onChanged: (newVal) {//newVal adalah idTusi yang dipilih (nilai dari value)
                        setState(() {
                          //getIdSubPekerjaanValue = null;
                          _state = newVal;
                          // tempList = provincesList
                          //     ?.where((x) =>
                          // x.idTusi.toString() == (_state.toString()))
                          //     .toList();
                        });

                        // print(testingList.toString());
                      },
//                      validator: (newVal) {
//                        if (newVal?.isEmpty ?? true) {
//                          return 'Aktivitas Diperlukan';
//                        }
//                        return null;
//                      },
                      value: _state,
                      hint: Text('Pilih Aktivitas'),
                    ),
                  ),
//                   Container(
//                     margin: EdgeInsets.only(left: 18.0, right: 18.0),
//                     child: new DropdownButton<String>(
//                       isExpanded: true,
//                       icon: const Icon(Icons.access_time),
//                       items: tempList?.map((item) {
//                         return new DropdownMenuItem<String>(
//                           child: new Text(item.standarWaktu),
//                           value: item.idSubPekerjaan.toString(),
//                         );
//                       }).toList(),
//                       onChanged: (newVal) {
//                         setState(() {
//                           getIdSubPekerjaanValue = newVal;
//                         });
//                       },
// //                      validator: (newVal) {
// //                        if (newVal?.isEmpty ?? true) {
// //                          return 'Standar Waktu Diperlukan';
// //                        }
// //                        return null;
// //                      },
//                       value: getIdSubPekerjaanValue,
//                       hint: Text('Pilih Standar Waktu'),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 15.0,
//                   ),
                  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  TextButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.greenAccent)))
                    ),
                    onPressed: () {
                      DatePicker.showTimePicker(context,
                          theme: DatePickerTheme(containerHeight: 210.0,),
                          showTitleActions: true, onConfirm: (time) {
                            print('confirm $time');
                            String jam = DateFormat('HH').format(time);
                            String menit = DateFormat('mm').format(time);
                            _timeMulai = (time.hour >= 0) ? '${jam}:${menit}'.padLeft(2,'0'):'${jam}:${menit}';//'${time.hour}:${time.minute}'.padLeft(2,"0");
                            setState(() {});},
                          currentTime: DateTime.now(),
                          showSecondsColumn: false,
                          locale: LocaleType.id);
                      setState(() {});
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
                                crossAxisAlignment: CrossAxisAlignment.start,//membuat isi kolom rata kiri
                                children: <Widget>[
                                  Text("Jam mulai",style: Theme.of(context).textTheme.caption),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.access_time,
                                          size: 18.0,
                                          color: Colors.teal,
                                        ),
                                        Text(
                                          " $_timeMulai",
                                          style: TextStyle(
                                              color: Colors.teal,
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
                          Text(
                            "  Ubah",
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
                  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  SizedBox(
                    height: 3.0,
                  ),
                  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  TextButton( //inputan jam selesai
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.greenAccent)))
                    ),
                    onPressed: (){
                      DatePicker.showTimePicker(context,
                          theme: DatePickerTheme(containerHeight: 210.0,),
                          showTitleActions: true, onConfirm: (time) {
                            print('confirm $time');
                            String jam = DateFormat('HH').format(time);
                            String menit = DateFormat('mm').format(time);
                            _timeSelesai = (time.hour >= 0) ? '${jam}:${menit}'.padLeft(2,'0'):'${jam}:${menit}';//'${time.hour}:${time.minute}'.padLeft(2,"0");
                            setState(() {});},
                          currentTime: DateTime.now(),
                          showSecondsColumn: false,
                          locale: LocaleType.id);
                      setState(() {});
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
                                crossAxisAlignment: CrossAxisAlignment.start,//membuat isi kolom rata kiri
                                children: <Widget>[
                                  Text("Jam Selesai",style: Theme.of(context).textTheme.caption),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.access_time,
                                          size: 18.0,
                                          color: Colors.teal,
                                        ),
                                        Text(
                                          " $_timeSelesai",
                                          style: TextStyle(
                                              color: Colors.teal,
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
                          Text(
                            "  Ubah",
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
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 18.0, right: 18.0),
                      child: TextFormField(
                        controller: ctrlUraianPekerjaan,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Uraian Pekerjaan',
                          hintText: 'Uraian Pekerjaan',
                        ),
                      )
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
                          _currentPosition!=null? Text('Latitude: ${_currentPosition?.latitude}') : Text('Menunggu Koordinat Lat'),
                          _currentPosition!=null? Text('Longitude: ${_currentPosition?.longitude}') : Text('Menunggu Koordinat Long'),
                          _currentAddress!=null? Text('Alamat: ${_currentAddress}') : Text('Menunggu Alamat'),
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
                    height: 10,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 18.0, right: 18.0),
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              if (validateInput()) {
                                DaftarAktivitas dataIn = new DaftarAktivitas(
                                    idPekerjaan: this.widget.daftaraktivitas != null
                                        ? this.widget.daftaraktivitas!.idPekerjaan
                                        : "",
                                    tglPekerjaan: _date,
                                    // idSubPekerjaan: getIdSubPekerjaanValue!,
                                    jamMulai: _timeMulai,
                                    jamSelesai: _timeSelesai,
                                    deskripsiPekerjaan: ctrlUraianPekerjaan.text,);
//                                    if(compareJamTanggal(dataIn, dataIn.tglKinerja, dataIn.jamSelesai)==true){
//                                      if(_date == "datedariserver" && _timeMulai<="timedariserver"){
//
//                                      }
                                    DateFormat dateFormat = new DateFormat.Hm();
                                    DateTime mulai = dateFormat.parse(_timeMulai);
                                    DateTime selesai = dateFormat.parse(_timeSelesai);
                                    if(mulai.isAfter(selesai)) {
                                      // tolak
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Jam selesai harus lebih dari jam mulai!"),
                                      ));

                                    }else{
                                      if (this.widget.daftaraktivitas != null) {
                                        api.update(dataIn, tokenlistaktivitas!)
                                            .then((result) {
                                          if (result=="true") {
                                            Navigator.pop(
                                                ScaffoldMessenger.of(context).context, true);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(result),
                                            ));
                                          }
                                        });
                                      } else {
                                        api.create(dataIn, tokenlistaktivitas!)
                                            .then((result) {
                                          if (result=="true") {
                                            Navigator.pop(
                                                ScaffoldMessenger.of(context).context, true);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(result),
                                            ));
                                            //                                            _scaffoldState.currentState
                                            //                                                .showSnackBar(SnackBar(
                                            //                                              content: Text(
                                            //                                                  "Simpan data gagal"),
                                            //                                            ));
                                          }
                                        });
                                      }
                                    }


//                                    }else{
//                                      _scaffoldState.currentState
//                                          .showSnackBar(SnackBar(
//                                        content: Text(
//                                            "Simpan data gagal"),
//                                      ));
//                                    }




                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Data belum lengkap"),
                                ));
                              }
                            },
                            child: Text(
                              widget.daftaraktivitas == null ? "Simpan" : "Ubah",
                              style: TextStyle(color: Colors.white),
                            ),
                            // color: Colors.orange[400],
                          ),
                        ],
                      )
                  )
                ],
              ),
            ],
          ),
        )
      )
    );
  }

  _getCurrentLocation() {
    loading = true!;
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng(_currentPosition!.latitude.toDouble(),_currentPosition!.longitude.toDouble());
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
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
    if (_date == "Belum diset" ||
        ctrlUraianPekerjaan.text == "" ||
        _timeMulai == ""||
        _timeSelesai == "" ) {
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