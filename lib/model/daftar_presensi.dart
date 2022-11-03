import 'dart:convert';

class DaftarPresensi{
  String? idOpd;
  String? idUsers;
  String? latitude;
  String? longitude;
  String? data_dukung;
  String? tipePresensi;
  String? tanggal;
  String? fullDate;
  int? numb;
  bool selected = false;

  DaftarPresensi({this.idOpd,this.idUsers,this.latitude,this.longitude,this.data_dukung,this.tipePresensi,this.tanggal,this.fullDate});
  
  factory DaftarPresensi.fromJson(Map<String, dynamic> map) {
    return DaftarPresensi(
      //idOpd: map["id_opd"],
      idUsers: map["id_users"],
      latitude: map["latitude"],
      longitude: map["longitude"],
      data_dukung: map["data_dukung"],
      tipePresensi: map["tipe_absen"],
      tanggal: map["tanggal"],
      fullDate: map["created_at"]
    );
  }

  static List<DaftarPresensi> daftarPresensiFromJson(String jsonData){
    final data = json.decode(jsonData);
    return List<DaftarPresensi>.from(data.map((item) => DaftarPresensi.fromJson(item)));
  }
}
