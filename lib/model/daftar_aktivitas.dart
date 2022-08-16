import 'dart:convert';
import 'package:kertas/model/daftar_pegawaiverifikasi.dart';

class DaftarAktivitas{
  String? idPekerjaan;
  String? idOpd;
  String? idUsers;
  String? idTusi;
  String? namaTugasFungsi;
  String? deskripsiPekerjaan;
  String? tglPekerjaan;
  String? jamMulai;
  String? jamSelesai;
  String? waktuMengerjakan;
  String? dataDukung;
  String? dateCreated;
  String? dateUpdated;
  int? numb;
  // String? idDataKinerja;
  // String? namaPekerjaan;
  // String? standarWaktu;
  // String? waktuDiakui;
  // String? namaSubPekerjaan;
  bool selected = false;

  DaftarAktivitas({this.idPekerjaan,this.idOpd,this.idUsers,this.idTusi,this.namaTugasFungsi,this.deskripsiPekerjaan,this.tglPekerjaan,this.jamMulai,this.jamSelesai,this.waktuMengerjakan,this.dataDukung,this.dateCreated,this.dateUpdated});
  
  factory DaftarAktivitas.fromJson(Map<String, dynamic> map) {
    return DaftarAktivitas(
      idPekerjaan: map["id"],
      idOpd: map["id_opd"],
      idUsers: map["id_users"],
      idTusi: map["id_tusi"],
      namaTugasFungsi: map["tusi"],
      deskripsiPekerjaan: map["deskripsi"],
      tglPekerjaan: map["tanggal"],
      jamMulai: map["waktu_mulai"],
      jamSelesai: map["waktu_selesai"],
      waktuMengerjakan: map["total_menit"],
      dataDukung: map["data_dukung"],
      dateCreated: map["date_created"],
      dateUpdated: map["date_updated"],
    );
  }

  static List<DaftarAktivitas> daftarAktivitasFromJson(String jsonData){
    final data = json.decode(jsonData);
    return List<DaftarAktivitas>.from(data.map((item) => DaftarAktivitas.fromJson(item)));
  }
}
