// ==========================================
// HELPER PARSERS
// ==========================================

double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.trim()) ?? defaultValue;
  }

  return defaultValue;
}

double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return null;
    }

    return double.tryParse(trimmedValue);
  }

  return null;
}

int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value.trim()) ?? defaultValue;
  }

  return defaultValue;
}

bool _parseBool(dynamic value, [bool defaultValue = false]) {
  if (value == null) return defaultValue;

  if (value is bool) {
    return value;
  }

  if (value is String) {
    final lowerValue = value.trim().toLowerCase();

    return lowerValue == 'true' ||
        lowerValue == 'tructuyen' ||
        lowerValue == 'online' ||
        lowerValue == '1';
  }

  if (value is num) {
    return value == 1;
  }

  return defaultValue;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;

  final rawValue = value.toString().trim();

  if (rawValue.isEmpty) {
    return null;
  }

  return DateTime.tryParse(rawValue);
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
  final String trangThaiDuyet;
  final String? lyDoKhongKhaDung;

  /// GPS phải nullable.
  ///
  /// null có nghĩa là shipper chưa gửi GPS hoặc API chưa trả GPS.
  final double? lat;
  final double? lng;

  /// Thời điểm backend ghi nhận GPS gần nhất.
  final DateTime? locationUpdatedAt;

  const ShipperModel({
    required this.id,
    required this.hoTen,
    required this.bienSo,
    required this.soDienThoai,
    required this.danhGia,
    required this.soDonDaGiao,
    required this.khoangCachKm,
    required this.thoiGianRanhPhut,
    required this.trangThaiDuyet,
    required this.lat,
    required this.lng,
    required this.locationUpdatedAt,
    this.isOnline = false,
    this.isOptimal = false,
    this.lyDoKhongKhaDung,
  });

  bool get hasValidLocation {
    final currentLat = lat;
    final currentLng = lng;

    if (currentLat == null || currentLng == null) {
      return false;
    }

    return currentLat >= -90 &&
        currentLat <= 90 &&
        currentLng >= -180 &&
        currentLng <= 180;
  }

  /// Có GPS nhưng dữ liệu đã quá 5 phút.
  ///
  /// Có thể điều chỉnh ngưỡng này theo nghiệp vụ.
  bool get isLocationStale {
    final updatedAt = locationUpdatedAt;

    if (updatedAt == null) {
      return true;
    }

    final now = updatedAt.isUtc ? DateTime.now().toUtc() : DateTime.now();

    return now.difference(updatedAt).inMinutes > 5;
  }

  factory ShipperModel.fromJson(Map<String, dynamic> json) {
    return ShipperModel(
      id:
          (json['maSp'] ??
                  json['MaSp'] ??
                  json['maTk'] ??
                  json['MaTk'] ??
                  json['id'] ??
                  json['Id'] ??
                  '')
              .toString(),

      hoTen: (json['hoTen'] ?? json['HoTen'] ?? 'Tài xế').toString(),

      bienSo:
          (json['bienSoXe'] ??
                  json['BienSoXe'] ??
                  json['bienSo'] ??
                  json['BienSo'] ??
                  'N/A')
              .toString(),

      soDienThoai: (json['soDienThoai'] ?? json['SoDienThoai'] ?? 'N/A')
          .toString(),

      danhGia: _parseDouble(json['danhGia'] ?? json['DanhGia'], 5.0),

      soDonDaGiao: _parseInt(json['soDonDaGiao'] ?? json['SoDonDaGiao']),

      khoangCachKm: _parseDouble(json['khoangCachKm'] ?? json['KhoangCachKm']),

      thoiGianRanhPhut: _parseInt(
        json['thoiGianRanhPhut'] ?? json['ThoiGianRanhPhut'],
      ),

      // Thiếu trạng thái phải xem là offline, không mặc định online.
      isOnline: _parseBool(
        json['trangThaiHoatDong'] ??
            json['TrangThaiHoatDong'] ??
            json['isOnline'] ??
            json['IsOnline'],
        false,
      ),

      isOptimal: _parseBool(json['isOptimal'] ?? json['IsOptimal']),

      trangThaiDuyet:
          (json['trangThaiHoSo'] ??
                  json['TrangThaiHoSo'] ??
                  json['trangThaiDuyet'] ??
                  json['TrangThaiDuyet'] ??
                  'ChoDuyet')
              .toString(),

      lyDoKhongKhaDung: (json['lyDoKhongKhaDung'] ?? json['LyDoKhongKhaDung'])
          ?.toString(),

      // Hỗ trợ cả field hiện tại và field backend dự kiến.
      lat: _parseNullableDouble(
        json['latitude'] ??
            json['Latitude'] ??
            json['viDo'] ??
            json['ViDo'] ??
            json['lat'] ??
            json['Lat'],
      ),

      lng: _parseNullableDouble(
        json['longitude'] ??
            json['Longitude'] ??
            json['kinhDo'] ??
            json['KinhDo'] ??
            json['lng'] ??
            json['Lng'],
      ),

      locationUpdatedAt: _parseDateTime(
        json['locationUpdatedAt'] ??
            json['LocationUpdatedAt'] ??
            json['thoiGianCapNhat'] ??
            json['ThoiGianCapNhat'],
      ),
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
      'latitude': lat,
      'longitude': lng,
      'locationUpdatedAt': locationUpdatedAt?.toIso8601String(),
    };
  }
}
