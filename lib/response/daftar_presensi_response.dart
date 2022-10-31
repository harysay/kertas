import 'package:kertas/model/daftar_aktivitas.dart';
import 'package:kertas/model/daftar_presensi.dart';

class DaftarPresensiResponse{
  String? status;
  String? info;
  List<DaftarPresensi>? data;

  DaftarPresensiResponse({this.status,
    this.info,
    this.data});

  factory DaftarPresensiResponse.fromJson(Map<String,dynamic>map){
    var allPresensi = map['data_absensi'] as List;
    List<DaftarPresensi> presensiList = allPresensi.map((i) => DaftarPresensi.fromJson(i)).toList();
    return DaftarPresensiResponse(
      status: map["status"],
        info: map["message"],
        data: presensiList
    );
  }
}