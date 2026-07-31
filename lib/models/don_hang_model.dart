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
    return lower == 'true' || lower == '1';
  }
  if (value is num) return value == 1;
  return defaultValue;
}

// ==========================================
// MODEL
// ==========================================
class DonHangModel {
  final String id;
  final String maDon;
  final String thoiGianCho;
  final double trongLuong;
  final String kichThuoc;
  final double dungTich;
  final String tinhChat;
  final String diemLayHang;
  final String lienHeLayHang;
  final String diemGiaoHang;
  final String lienHeGiaoHang;
  final int duKienGiaoPhut;
  final String giaCuoc;
  final String hinhThucGiao;
  final String tienCod;
  final double quangDuongKm;
  final bool isUrgent;

  DonHangModel({
    required this.id,
    required this.maDon,
    required this.thoiGianCho,
    required this.trongLuong,
    required this.kichThuoc,
    required this.dungTich,
    required this.tinhChat,
    required this.diemLayHang,
    required this.lienHeLayHang,
    required this.diemGiaoHang,
    required this.lienHeGiaoHang,
    required this.duKienGiaoPhut,
    required this.giaCuoc,
    required this.hinhThucGiao,
    required this.tienCod,
    required this.quangDuongKm,
    this.isUrgent = false,
  });

  factory DonHangModel.fromJson(Map<String, dynamic> json) {
    return DonHangModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      maDon: (json['maDon'] ?? json['MaDon'] ?? '#ORD-UNKNOWN').toString(),
      thoiGianCho: (json['thoiGianCho'] ?? json['ThoiGianCho'] ?? '00:00').toString(),
      trongLuong: _parseDouble(json['trongLuong'] ?? json['TrongLuong']),
      kichThuoc: (json['kichThuoc'] ?? json['KichThuoc'] ?? 'N/A').toString(),
      dungTich: _parseDouble(json['dungTich'] ?? json['DungTich']),
      tinhChat: (json['tinhChat'] ?? json['TinhChat'] ?? 'THƯỜNG').toString(),
      diemLayHang: (json['diemLayHang'] ?? json['DiemLayHang'] ?? '').toString(),
      lienHeLayHang: (json['lienHeLayHang'] ?? json['LienHeLayHang'] ?? '').toString(),
      diemGiaoHang: (json['diemGiaoHang'] ?? json['DiemGiaoHang'] ?? '').toString(),
      lienHeGiaoHang: (json['lienHeGiaoHang'] ?? json['LienHeGiaoHang'] ?? '').toString(),
      duKienGiaoPhut: _parseInt(json['duKienGiaoPhut'] ?? json['DuKienGiaoPhut']),
      giaCuoc: (json['giaCuoc'] ?? json['GiaCuoc'] ?? '0đ').toString(),
      hinhThucGiao: (json['hinhThucGiao'] ?? json['HinhThucGiao'] ?? 'Tiêu chuẩn').toString(),
      tienCod: (json['tienCod'] ?? json['TienCod'] ?? '0đ').toString(),
      quangDuongKm: _parseDouble(json['quangDuongKm'] ?? json['QuangDuongKm']),
      isUrgent: _parseBool(json['isUrgent'] ?? json['IsUrgent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maDon': maDon,
      'thoiGianCho': thoiGianCho,
      'trongLuong': trongLuong,
      'kichThuoc': kichThuoc,
      'dungTich': dungTich,
      'tinhChat': tinhChat,
      'diemLayHang': diemLayHang,
      'lienHeLayHang': lienHeLayHang,
      'diemGiaoHang': diemGiaoHang,
      'lienHeGiaoHang': lienHeGiaoHang,
      'duKienGiaoPhut': duKienGiaoPhut,
      'giaCuoc': giaCuoc,
      'hinhThucGiao': hinhThucGiao,
      'tienCod': tienCod,
      'quangDuongKm': quangDuongKm,
      'isUrgent': isUrgent,
    };
  }

  DonHangModel copyWith({
    String? id,
    String? maDon,
    String? thoiGianCho,
    double? trongLuong,
    String? kichThuoc,
    double? dungTich,
    String? tinhChat,
    String? diemLayHang,
    String? lienHeLayHang,
    String? diemGiaoHang,
    String? lienHeGiaoHang,
    int? duKienGiaoPhut,
    String? giaCuoc,
    String? hinhThucGiao,
    String? tienCod,
    double? quangDuongKm,
    bool? isUrgent,
  }) {
    return DonHangModel(
      id: id ?? this.id,
      maDon: maDon ?? this.maDon,
      thoiGianCho: thoiGianCho ?? this.thoiGianCho,
      trongLuong: trongLuong ?? this.trongLuong,
      kichThuoc: kichThuoc ?? this.kichThuoc,
      dungTich: dungTich ?? this.dungTich,
      tinhChat: tinhChat ?? this.tinhChat,
      diemLayHang: diemLayHang ?? this.diemLayHang,
      lienHeLayHang: lienHeLayHang ?? this.lienHeLayHang,
      diemGiaoHang: diemGiaoHang ?? this.diemGiaoHang,
      lienHeGiaoHang: lienHeGiaoHang ?? this.lienHeGiaoHang,
      duKienGiaoPhut: duKienGiaoPhut ?? this.duKienGiaoPhut,
      giaCuoc: giaCuoc ?? this.giaCuoc,
      hinhThucGiao: hinhThucGiao ?? this.hinhThucGiao,
      tienCod: tienCod ?? this.tienCod,
      quangDuongKm: quangDuongKm ?? this.quangDuongKm,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }
}