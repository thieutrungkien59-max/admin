// ==========================================
// HELPER PARSERS (Chống crash)
// ==========================================
double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

bool _parseBool(dynamic value, [bool defaultValue = false]) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == 'tructuyen' || lower == 'online' || lower == '1';
  }
  if (value is num) return value == 1;
  return defaultValue;
}

// ==========================================
// SHIPPER MODEL
// ==========================================
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
  final String trangThaiDuyet; // 'ChoDuyet', 'DaDuyet', 'TuChoi'
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
    this.trangThaiDuyet = 'ChoDuyet', // Mặc định là ChoDuyet nếu backend không gửi
    this.lyDoKhongKhaDung,
    this.lat = 10.7769,
    this.lng = 106.7009,
  });

  factory ShipperModel.fromJson(Map<String, dynamic> json) {
    return ShipperModel(
      id: (json['maSp'] ?? json['maTk'] ?? json['id'] ?? json['Id'] ?? '').toString(),
      hoTen: (json['hoTen'] ?? json['HoTen'] ?? 'Tài xế').toString(),
      bienSo: (json['bienSoXe'] ?? json['bienSo'] ?? json['BienSo'] ?? 'N/A').toString(),
      soDienThoai: (json['soDienThoai'] ?? json['SoDienThoai'] ?? 'N/A').toString(),
      danhGia: _parseDouble(json['danhGia'] ?? json['DanhGia'], 5.0),
      soDonDaGiao: _parseInt(json['soDonDaGiao'] ?? json['SoDonDaGiao']),
      khoangCachKm: _parseDouble(json['khoangCachKm'] ?? json['KhoangCachKm']),
      thoiGianRanhPhut: _parseInt(json['thoiGianRanhPhut'] ?? json['ThoiGianRanhPhut']),
      isOnline: _parseBool(
        json['trangThaiHoatDong'] ?? json['isOnline'] ?? json['IsOnline'],
        true,
      ),
      isOptimal: _parseBool(json['isOptimal'] ?? json['IsOptimal']),
    trangThaiDuyet: (json['trangThaiHoSo'] ?? json['TrangThaiHoSo'] ?? json['trangThaiDuyet'] ?? 'ChoDuyet').toString(),
      lyDoKhongKhaDung: json['lyDoKhongKhaDung'] ?? json['LyDoKhongKhaDung'],
      lat: _parseDouble(json['lat'] ?? json['Lat'], 10.7769),
      lng: _parseDouble(json['lng'] ?? json['Lng'], 106.7009),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maSp': id,
      'hoTen': hoTen,
      'bienSoXe': bienSo,
      'soDienThoai': soDienThoai,
      'danhGia': danhGia,
      'soDonDaGiao': soDonDaGiao,
      'khoangCachKm': khoangCachKm,
      'thoiGianRanhPhut': thoiGianRanhPhut,
      'trangThaiHoatDong': isOnline ? 'TrucTuyen' : 'NgoaiTuyen',
      'isOptimal': isOptimal,
      'trangThaiDuyet': trangThaiDuyet,
      'lyDoKhongKhaDung': lyDoKhongKhaDung,
      'lat': lat,
      'lng': lng,
    };
  }

  ShipperModel copyWith({
    String? id,
    String? hoTen,
    String? bienSo,
    String? soDienThoai,
    double? danhGia,
    int? soDonDaGiao,
    double? khoangCachKm,
    int? thoiGianRanhPhut,
    bool? isOnline,
    bool? isOptimal,
    String? trangThaiDuyet,
    String? lyDoKhongKhaDung,
    double? lat,
    double? lng,
  }) {
    return ShipperModel(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      bienSo: bienSo ?? this.bienSo,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      danhGia: danhGia ?? this.danhGia,
      soDonDaGiao: soDonDaGiao ?? this.soDonDaGiao,
      khoangCachKm: khoangCachKm ?? this.khoangCachKm,
      thoiGianRanhPhut: thoiGianRanhPhut ?? this.thoiGianRanhPhut,
      isOnline: isOnline ?? this.isOnline,
      isOptimal: isOptimal ?? this.isOptimal,
      trangThaiDuyet: trangThaiDuyet ?? this.trangThaiDuyet,
      lyDoKhongKhaDung: lyDoKhongKhaDung ?? this.lyDoKhongKhaDung,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}