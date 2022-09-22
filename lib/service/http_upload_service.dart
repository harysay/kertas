import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ApiService.dart';

class HttpUploadService {
  ApiService api = new ApiService();
  
  Future<String> uploadPhotos(String path,String token, String idOpd, String isUser, String idTusi, String deskripsi, String tanggal,String waktuMulai, String waktuSelesai) async {
    Uri uri = Uri.parse(api.baseUrl+"pekerjaan/tambahpekerjaan");
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = token;
    request.fields['id_opd'] = idOpd;
    request.fields['id_users'] = isUser;
    request.fields['id_tusi'] = idTusi;
    request.fields['deskripsi'] = deskripsi;
    request.fields['tanggal'] = tanggal;
    request.fields['waktu_mulai'] = waktuMulai;
    request.fields['waktu_selesai'] = waktuSelesai;
    request.files.add(await http.MultipartFile.fromPath('data_dukung', path));


    http.StreamedResponse response = await request.send();
    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);
    final data = jsonDecode(responseString);
    String status = data['status'];
    String pesanError = data['message'];
    if(status=="success") {
      return status;
    }else{
      return pesanError;
    }
  }

}