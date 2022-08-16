import 'package:kertas/model/data_tusi.dart';

class DaftarTusiResponse{
  String? status;
  String? info;
  List<DataTusi>? data;

  DaftarTusiResponse({this.status,
    this.info,
    this.data});

  factory DaftarTusiResponse.fromJson(Map<String,dynamic>map){
    var allTusi = map['tusi_data'] as List;
    List<DataTusi> tusiList = allTusi.map((i) => DataTusi.fromJson(i)).toList();
    return DaftarTusiResponse(
        status: map["status"],
        info: map["message"],
        data: tusiList
    );
  }
}