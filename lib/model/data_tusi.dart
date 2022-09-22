class DataTusi {
  final String idTusi;
  final String namaTusi;
  //final List<String> subPekerjaan;

  DataTusi({
    required this.idTusi,
    required this.namaTusi
    //this.subPekerjaan
  });

  factory DataTusi.fromJson(Map<String, dynamic> parsedJson) {
    // var dd = parsedJson['data'];
    //List<String> sss = dd.cast<String>();
    return DataTusi(
      idTusi: parsedJson['id_tusi'],
      namaTusi: parsedJson['nama'],
      //subPekerjaan: sss
    );
  }

}