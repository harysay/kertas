import 'dart:convert';
import 'package:kertas/fragments/verifikasi_fragment.dart';
import 'package:kertas/model/daftar_pegawaiverifikasi.dart';
import 'package:kertas/model/daftar_presensi.dart';
import 'package:kertas/model/data_tusi.dart';
import 'package:kertas/response/daftarTusiResponse.dart';
import 'package:kertas/response/daftar_aktivitas_response_var.dart';
import 'package:http/http.dart' as http;
import 'package:kertas/model/daftar_aktivitas.dart';
import 'package:kertas/response/daftar_aktivitas_response.dart';
import 'package:kertas/response/daftar_pegawaiverifikasi_response.dart';
import 'package:kertas/response/daftar_presensi_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  String username="", nama="",tokenlogin="", usernama="",passkode="",iduser="";
  //Development
  String urlGetdataPribadi = "https://development.kebumenkab.go.id/siltapkin/index.php/api/rekam/dataDiri?token=";
  // String baseUrl = "https://development.kebumenkab.go.id/kertas/index.php/api/";
  String baseUrl = "http://10.28.11.13/kertas_v2/index.php/api/";//laptope imam
  // String baseLamaAktivitas = "https://development.kebumenkab.go.id/kertas/index.php/api/pekerjaan/getpekerjaanbyhari/";
  // static String baseUrlLogin = "https://development.kebumenkab.go.id/siltapkin/index.php/api/login/proseslogin";
  // static String baseUrlLogin = "https://development.kebumenkab.go.id/kertas/index.php/api/auth/login";
  static String baseTampilPegawaiVerifikasi = "https://development.kebumenkab.go.id/siltapkin/index.php/api/verifikasi/";
  // static String baseLaporan = "https://development.kebumenkab.go.id/siltapkin/index.php/api/laporan/";
  // static String baseStatusLogout = "https://development.kebumenkab.go.id/siltapkin/index.php/api/Login/proses_logout";
  //static String baseStatusRunning = "https://development.kebumenkab.go.id/kertas/index.php/api/app/status";
  static String baseSudahverfiPribadi = "https://development.kebumenkab.go.id/siltapkin/index.php/api/rekam/verif_individu_bulanan?token=";
  String baseDaftarPekerjaan = "https://development.kebumenkab.go.id/siltapkin/index.php/api/master_data/pekerjaan_lepas?token=";
  static String versionCodeSekarang = "9"; //harus sama dengan version di buildernya
  static String versionBuildSekarang = "Version 1.0.db.06062022";

  //Production

  getPrefFromApi() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    tokenlogin = preferences.getString("tokenlogin")!;
    iduser = preferences.getString("userid")!;

  }

  Future<bool> loginAplikasi(String user, String kode) async {
    // untuk post wajib ada body properti
    final response = await http.post(Uri.parse(baseUrl+"auth/login"),
        body: {
      // sesuaikan dengan key yg sudah dibuat pada api
      "username": user, // key username kemudian nilai inputnya dari mana,  dari string username
      "password": kode // key password kemudian nilai inputnya dari mana,  dari string password
    });
    // harus ada decode, karena setiap resul yg sudah di encode, wajib kita decode
    final data = jsonDecode(response.body);
    String userId = data['id_user'];
    String status = data['status'];
    String idOpd = data['id_opd'];
    String namaOpd = data['nama_opd'];
    String tokenLogin = data['token'];
    String nikLogin = data['username'];
    String namaLogin = data['nama'];
    String namaBidang = data['nama_bidang'];
    String fotoLog = data['foto'];
    String akseslevel = data['access_level'];
    String idFormasi = data['id_formasi'];
    // String idPegawai = data['id_user'];
    if (status == "success") {
        // _loginStatus = LoginStatus.signIn;
        await savePref(userId, status, tokenLogin, nikLogin,namaLogin,namaBidang,idOpd,namaOpd,fotoLog,akseslevel,idFormasi);
      return true;
    } else {
      return false;
    }
  }
  savePref(String userId, String status,String tokenlog, String nik, String nama, String namBidang, String idOpd,String namOpd, String fotoLogin,String aksesLevel,String idformasi) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("userid",  userId);
      preferences.setString("status", status);
      preferences.setString("niklogin", nik);
      preferences.setString("tokenlogin", tokenlog);
      preferences.setString("namalogin", nama);
      preferences.setString("namabidang", namBidang);
      preferences.setString("idopd", idOpd);
      preferences.setString("namaopd", namOpd);
      preferences.setString("fotoLogin", fotoLogin);
      preferences.setString("akseslevel", aksesLevel);
      preferences.setString("idformasi", idformasi);
      // preferences.setString("id", idpegawai);
      preferences.commit();
  }

  //  Future<String>getLamaAktivitas(String idPegawai,String tokenLog)async{
  //   String tarikanLamaAktivitas="",pesan = "";
  //   final response = await http.get(Uri.parse(baseLamaAktivitas+idPegawai),
  //        headers: {
  //          "Accept": "application/json",
  //          "Content-Type": "application/x-www-form-urlencoded",
  //          "authorization": tokenLog
  //        },);
  //   if(response.statusCode == 200){
  //     var data = jsonDecode(response.body);
  //     tarikanLamaAktivitas = data["total_menit"];
  //     pesan = data["message"];
  //     return tarikanLamaAktivitas;
  //   }else{
  //     return pesan;
  //   }
  // }

  DaftarPegawaiVerifikasiResponse pegawairesponse = new DaftarPegawaiVerifikasiResponse();
  Future<List<DaftarPegawaiVerifikasi>?> getAllPegawaiVer(String tokenDafAktiv) async {
    //Map<String, dynamic> inputMap = {'DEMO-API-KEY': '$key'};
    getPrefFromApi();
    final response = await http.post(Uri.parse(
      baseTampilPegawaiVerifikasi + "tampilpegawai?token="+tokenDafAktiv),
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "authorization": basicAuth
//      },
//      body: inputMap,
    );

    pegawairesponse = DaftarPegawaiVerifikasiResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      List<DaftarPegawaiVerifikasi>? data = pegawairesponse.data;
      return data;
    } else {
      return null;
    }
  }

  DaftarAktivitasResponse rAlActivity = new DaftarAktivitasResponse();
  getSemuaAktivitas(String tokenListAktivitas)async{
    final response = await http.get(Uri.parse(baseUrl+"tampildaftar?token="+tokenListAktivitas));
    rAlActivity = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      var data = rAlActivity.data;
      return data;
    } else {
      return null;
    }
  }

  DaftarAktivitasResponse rSudahverfiPribadi = new DaftarAktivitasResponse();
  Future<List<DaftarAktivitas>?> getSudahverfiPribadi(String tokenverfi)async{
    DateTime now = new DateTime.now();
    var bulan;
    if(now.day<2){
      bulan = now.month-1;
    }else{
      bulan = now.month;
    }
    final response = await http.get(Uri.parse(baseSudahverfiPribadi+tokenverfi+"&bulan="+bulan.toString()+"&tahun="+now.year.toString()),
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "authorization": basicAuth
//      },
//      body: inputMap,
    );

    rSudahverfiPribadi = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      List<DaftarAktivitas>? data = rSudahverfiPribadi.data;
      return data;
    } else {
      return null;
    }
  }

  DaftarAktivitasResponse rverfi = new DaftarAktivitasResponse();
  Future<List<DaftarAktivitas>?> getAllActivityVer(String tokenverfi, String idPns) async {
    //Map<String, dynamic> inputMap = {'DEMO-API-KEY': '$key'};
    final response = await http.get(Uri.parse(baseTampilPegawaiVerifikasi+"tampilpegawaidetail?token="+tokenverfi+"&id_pns="+idPns),
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "authorization": basicAuth
//      },
//      body: inputMap,
    );

    rverfi = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      List<DaftarAktivitas>? dat = rverfi.data;
      return dat;
    } else {
      return null;
    }
  }

//   DaftarTusiResponse tusiRes = new DaftarTusiResponse();
//   getAllDataTusi(String tokentusi) async {
//     await getPrefFromApi();
//     //Map<String, dynamic> inputMap = {'DEMO-API-KEY': '$key'};
//     final response = await http.get(Uri.parse(baseUrl+"tusi/gettusibyformasi/3"),
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "Authorization": tokenlogin
//      },
// //      body: inputMap,
//     );
//
//     tusiRes = DaftarTusiResponse.fromJson(json.decode(response.body));
//     if (response.statusCode == 200) {
//       List<DataTusi>? dat = tusiRes.data;
//       return dat;
//     } else {
//       return null;
//     }
//   }
//  static String username = 'user';
//  static String password = 'demo';
//  final String key = 'r4h4514';
//  final String basicAuth =
//      'Basic ' + base64Encode(utf8.encode('$username:$password'));

  DaftarPresensiResponse presensi = new DaftarPresensiResponse();
  Future<List<DaftarPresensi>?> getAllPresensiById() async {
    //Map<String, dynamic> inputMap = {'DEMO-API-KEY': '$key'};
    await getPrefFromApi();
    final response = await http.get(Uri.parse(baseUrl+"absensi/absenbyusers/"+iduser),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "authorization": tokenlogin
      },
//      body: inputMap,
    );

    presensi = DaftarPresensiResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      List<DaftarPresensi>? data = presensi.data;
      return data;
    } else {
      return null;
    }
  }

  DaftarAktivitasResponse aktivitasBelum = new DaftarAktivitasResponse();
  Future<List<DaftarAktivitas>?> getAllAktivitasById() async {
    //Map<String, dynamic> inputMap = {'DEMO-API-KEY': '$key'};
    await getPrefFromApi();
    final response = await http.get(Uri.parse(baseUrl+"pekerjaan/getpekerjaanbyuser/"+iduser),
           headers: {
       "Accept": "application/json",
       "Content-Type": "application/x-www-form-urlencoded",
       "authorization": tokenlogin
     },
//      body: inputMap,
    );

    aktivitasBelum = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      List<DaftarAktivitas>? data = aktivitasBelum.data;
      return data;
    } else {
      return null;
    }
  }

  DaftarAktivitasResponse aktivitasByID = new DaftarAktivitasResponse();
  Future<List<DaftarAktivitas>?> aktivitasById(String tokenByID, String idDataKinerja) async {
    //getPrefFromApi();
    Map<String, dynamic> inputMap = {
//      'DEMO-API-KEY': '$key',
      //'numb': aktivitas.numb,
      'id_data_kinerja': idDataKinerja,
    };
    final response = await http.post(Uri.parse(
      baseUrl + "tampildetail?token="+tokenByID),
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "authorization": basicAuth
//      },
      body: inputMap,
    );

    aktivitasByID = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    if (aktivitasByID.status == "true") {
      List<DaftarAktivitas>? data = aktivitasByID.data;
      return data;
    } else {
      return null;
    }
  }

  DaftarAktivitasResponse pekerjaanCreate = new DaftarAktivitasResponse();
  Future<String> uploadPhotos(DaftarAktivitas aktivitas,String path,String token) async {
    Uri uri = Uri.parse(api.baseUrl+"pekerjaan/tambahpekerjaan");
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = token;
    request.fields['id_opd'] = aktivitas.idOpd!;
    request.fields['id_users'] = aktivitas.idUsers!;
    request.fields['id_tusi'] = aktivitas.idTusi!;
    request.fields['deskripsi'] = aktivitas.deskripsiPekerjaan!;
    request.fields['tanggal'] = aktivitas.tglPekerjaan!;
    request.fields['waktu_mulai'] = aktivitas.jamMulai!;
    request.fields['waktu_selesai'] = aktivitas.jamSelesai!;
    request.files.add(await http.MultipartFile.fromPath('data_dukung', path));


    http.StreamedResponse response = await request.send();
    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);
    pekerjaanCreate = DaftarAktivitasResponse.fromJson(json.decode(responseString));
    if (pekerjaanCreate.status == "success") {
      return pekerjaanCreate.status!;
    } else {
      return pekerjaanCreate.info!;
    }
    // final data = jsonDecode(responseString);
    // String status = data['status'];
    // String pesanError = data['message'];
    // if(status=="success") {
    //   return status;
    // }else{
    //   return pesanError;
    // }
  }

  DaftarAktivitasResponse pekerjaanUpdate = new DaftarAktivitasResponse();
  Future<String> updatePekerjaan(DaftarAktivitas aktivitas,String path,String token) async {
    Uri uri = Uri.parse(api.baseUrl+"pekerjaan/ubahpekerjaan");
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = token;
    request.fields['id_pekerjaan'] = aktivitas.idPekerjaan!;
    request.fields['id_tusi'] = aktivitas.idTusi!;
    request.fields['deskripsi'] = aktivitas.deskripsiPekerjaan!;
    request.files.add(await http.MultipartFile.fromPath('data_dukung', path));


    http.StreamedResponse response = await request.send();
    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);
    pekerjaanCreate = DaftarAktivitasResponse.fromJson(json.decode(responseString));
    if (pekerjaanCreate.status == "success") {
      return pekerjaanCreate.status!;
    } else {
      return pekerjaanCreate.info!;
    }
    // final data = jsonDecode(responseString);
    // String status = data['status'];
    // String pesanError = data['message'];
    // if(status=="success") {
    //   return status;
    // }else{
    //   return pesanError;
    // }
  }

//create
//   DaftarAktivitasResponse aktivitasCreate = new DaftarAktivitasResponse();
//   Future<String> create(DaftarAktivitas aktivitas, String path, String tokenCreate) async {
//     //getPrefFromApi();
//     Map<String, dynamic> inputMap = {
//       //'DEMO-API-KEY': '$key',
//       'id_opd': aktivitas.idOpd,
//       'id_users': aktivitas.idUsers,
//       'id_tusi': aktivitas.idTusi,
//       'deskripsi': aktivitas.deskripsiPekerjaan,
//       'tanggal': aktivitas.tglPekerjaan,
//       //'nama_pekerjaan': aktivitas.namaPekerjaan,
//       //'waktu_mengerjakan': aktivitas.waktuMengerjakan,
//       //'standar_waktu': aktivitas.standarWaktu,
//       'waktu_mulai': aktivitas.jamMulai,
//       'waktu_selesai': aktivitas.jamSelesai,
//
//       'data_dukung': aktivitas.dataDukung,
//       //'status': aktivitas.status
//     };
//
//     final response = await http.post(Uri.parse(baseUrl+"pekerjaan/tambahpekerjaan"),
//       //headers: {"content-type": "application/json"},
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "authorization": tokenCreate
//      },
//       body: inputMap
//     );
//
//     aktivitasCreate = DaftarAktivitasResponse.fromJson(json.decode(response.body));
//     //if (response.statusCode == 200) {
//     if (aktivitasCreate.status == "true") {
//       return aktivitasCreate.status!;
//     } else {
//       return aktivitasCreate.info!;
//     }
//   }

  DaftarAktivitasResponse aktivitasUpdate = new DaftarAktivitasResponse();
  Future<String> update(DaftarAktivitas aktivitas, String tokenUpdate) async {
    //getPrefFromApi();
    Map<String, dynamic> inputMap = {
//      'DEMO-API-KEY': '$key',
      //'numb': aktivitas.numb,
      'id_pekerjaan': aktivitas.idPekerjaan,
      'id_tusi': aktivitas.idTusi,
      'deskripsi': aktivitas.deskripsiPekerjaan,
      'data_dukung': aktivitas.dataDukung,
      // 'jam_mulai': aktivitas.jamMulai,
      // 'jam_selesai': aktivitas.jamSelesai,
    };
    final response = await http.post(Uri.parse(baseUrl + "update?token="+tokenUpdate+"&id_data_kinerja="+aktivitas.idPekerjaan!),
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "authorization": basicAuth
//      },
      body: inputMap,
    );

    aktivitasUpdate = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    if (aktivitasUpdate.status == "success") {
      return aktivitasUpdate.status!;
    } else {
      return aktivitasUpdate.info!;
    }
  }

  Future<String?> delete(String idDataKinerja,String tokenDelete) async {
    await getPrefFromApi();
    Map<String, dynamic> inputMap = {
      //'DEMO-API-KEY': '$key',
      'id_pekerjaan': idDataKinerja
    };
    final response = await http.post(Uri.parse(baseUrl + "pekerjaan/hapuspekerjaan"),
     headers: {
       "Accept": "application/json",
       "Content-Type": "application/x-www-form-urlencoded",
       "authorization": tokenDelete
     },
     body: inputMap,
    );

    aktivitasBelum = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    //if (response.statusCode == 200) {
    if (aktivitasBelum.status == "success") {
      return aktivitasBelum.status;
    } else {
      return aktivitasBelum.info;
    }
  }

  DaftarAktivitasResponse rfi = new DaftarAktivitasResponse();
  setujuiAktivitas(String token, String idDataKinerja, String waktuDiakui, String tglKinerja)async{
    final response = await http.get(Uri.parse(baseTampilPegawaiVerifikasi+"verifikasisatu?token="+token+"&id_kinerja="+idDataKinerja+"&status_verifikasi=Diterima&waktu_diakui="+waktuDiakui+"&tgl_kinerja="+tglKinerja,));
    if (response.statusCode == 200) {
      List<DaftarAktivitas>? data = rfi.data;
      return data;
    } else {
      return null;
    }
  }

  DaftarAktivitasResponse rfiKembalikan = new DaftarAktivitasResponse();
  kembalikanAktivitas(String token, String idDataKinerja, String statusVerifikasi, String keterangan)async{
    Map<String, dynamic> inputMap = {
      //'DEMO-API-KEY': '$key',
      'token': token,
      'id_kinerja': idDataKinerja,
      'status_verifikasi': statusVerifikasi,
      'keterangan': keterangan,
    };
    final response = await http.post(Uri.parse(
      baseTampilPegawaiVerifikasi+"tolakkembalikan"),
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "authorization": basicAuth
//      },
      body: inputMap,
    );
    rfiKembalikan = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      List<DaftarAktivitas>? data = rfiKembalikan.data;
      return data;
    } else {
      return null;
    }
  }

  DaftarAktivitasResponse rfiTolak = new DaftarAktivitasResponse();
  tolakAktivitas(String token, String idDataKinerja, String statusVerifikasi, String keterangan)async{
    Map<String, dynamic> inputMap = {
      //'DEMO-API-KEY': '$key',
      'token': token,
      'id_kinerja': idDataKinerja,
      'status_verifikasi': statusVerifikasi,
      'keterangan': keterangan,
    };
    final response = await http.post(Uri.parse(
      baseTampilPegawaiVerifikasi+"tolakkembalikan"),
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/x-www-form-urlencoded",
//        "authorization": basicAuth
//      },
      body: inputMap,
    );
    rfiTolak = DaftarAktivitasResponse.fromJson(json.decode(response.body));
    if (response.statusCode == 200) {
      List<DaftarAktivitas>? data = rfiTolak.data;
      return data;
    } else {
      return null;
    }
  }


  laporanInividu(String bulanGet, String tahunGet) async {
    await getPrefFromApi();
    final response = await http.get(Uri.parse(baseUrl+"pekerjaan/getpekerjaanbytanggal/"+iduser+"/"+tahunGet+bulanGet,),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "authorization": tokenlogin
      },);
    var dataObjJson = jsonDecode(response.body)['pekerjaan_data'] as List;
//    List dataObjs = dataObjJson.map((e) => DaftarAktivitas.fromJson(e)).toList();
    if (response.statusCode == 200) {
      if(dataObjJson.isEmpty){
        dataObjJson = jsonDecode('[{}]');
      }
      return dataObjJson;
    } else{
      return null;
    }
//    lapIndividu = DaftarAktivitasResponse.fromJson(json.decode(response.body));
//    if (response.statusCode == 200) {
//      if(lapIndividu.status == "true"){
//        var data = lapIndividu.data;
//        return data;
//      }
//
//    } else {
//      return null;
//    }
  }

  laporanInividuTahunan(String tokenByID, String tahunGet) async {
    final response = await http.get(Uri.parse(baseUrl+"laporan/individu_tahunan?tahun="+tahunGet+"&token="+tokenByID,));
    var dataObjJsonTahunan = jsonDecode(response.body)['data'] as List;
//    List dataObjs = dataObjJson.map((e) => DaftarAktivitas.fromJson(e)).toList();
    if (response.statusCode == 200) {
      //jsonku = dataObjs;
      if(dataObjJsonTahunan.isEmpty){
        dataObjJsonTahunan = jsonDecode('[{}]');
      }
      return dataObjJsonTahunan;
    } else{
      return null;
    }
  }

//   kirimStatusLogout(String id_pns) async {
//     Map<String, dynamic> inputMap = {
//       'id_pns': id_pns,
//     };
//     final response = await http.post(Uri.parse(baseStatusLogout),
//       body: inputMap,
//     );
//     var objLogout = jsonDecode(response.body)['data'] as List;
// //    List dataObjs = dataObjJson.map((e) => DaftarAktivitas.fromJson(e)).toList();
//     if (response.statusCode == 200) {
//       //jsonku = dataObjs;
//       return objLogout;
//     } else{
//       return null;
//     }
//   }


}