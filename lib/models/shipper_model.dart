class ShipperModel {
  final String id;
  final String hoTen;
  final String bienSo;
  final String soDienThoai;
  final double danhGia;
  final int soDonDaGiao;
  final double khoangCachKm;
  final int thoiGianRanhPhut;
  final bool isOnline;
  final bool isOptimal;
  final String? lyDoKhongKhaDung;
  final double lat;
  final double lng;

  ShipperModel({
    required this.id,
    required this.hoTen,
    required this.bienSo,
    required this.soDienThoai,
    required this.danhGia,
    required this.soDonDaGiao,
    required this.khoangCachKm,
    required this.thoiGianRanhPhut,
    this.isOnline = true,
    this.isOptimal = false,
    this.lyDoKhongKhaDung,
    this.lat = 10.7769,
    this.lng = 106.7009,
  });

  factory ShipperModel.fromJson(Map<String, dynamic> json) {
    return ShipperModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      hoTen: json['hoTen'] ?? json['HoTen'] ?? 'Tài xế',
      bienSo: json['bienSo'] ?? json['BienSo'] ?? 'N/A',
      soDienThoai: json['soDienThoai'] ?? json['SoDienThoai'] ?? 'N/A',
      danhGia: ((json['danhGia'] ?? json['DanhGia'] ?? 5.0) as num).toDouble(),
      soDonDaGiao: json['soDonDaGiao'] ?? json['SoDonDaGiao'] ?? 0,
      khoangCachKm: ((json['khoangCachKm'] ?? json['KhoangCachKm'] ?? 0) as num).toDouble(),
      thoiGianRanhPhut: json['thoiGianRanhPhut'] ?? json['ThoiGianRanhPhut'] ?? 0,
      isOnline: json['isOnline'] ?? json['IsOnline'] ?? true,
      isOptimal: json['isOptimal'] ?? json['IsOptimal'] ?? false,
      lyDoKhongKhaDung: json['lyDoKhongKhaDung'] ?? json['LyDoKhongKhaDung'],
      lat: ((json['lat'] ?? json['Lat'] ?? 10.7769) as num).toDouble(),
      lng: ((json['lng'] ?? json['Lng'] ?? 106.7009) as num).toDouble(),
    );
  }
}