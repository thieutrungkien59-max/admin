// ==========================================
// HELPER PARSERS (Chống crash)
// ==========================================
double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
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
class CodModel {
  final String id;
  final String maDon;
  final String tenShipper;
  final double soTienCod;
  final bool isCompleted;
  final String ngayGiao;

  CodModel({
    required this.id,
    required this.maDon,
    required this.tenShipper,
    required this.soTienCod,
    required this.isCompleted,
    required this.ngayGiao,
  });

  factory CodModel.fromJson(Map<String, dynamic> json) {
    return CodModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      maDon: (json['maDon'] ?? json['MaDon'] ?? 'N/A').toString(),
      tenShipper: (json['tenShipper'] ?? json['TenShipper'] ?? 'N/A').toString(),
      soTienCod: _parseDouble(json['soTienCod'] ?? json['SoTienCod']),
      isCompleted: _parseBool(json['isCompleted'] ?? json['IsCompleted']) ||
          (json['trangThai'] == 'DA_DOI_SOAT'),
      ngayGiao: (json['ngayGiao'] ?? json['NgayGiao'] ?? 'N/A').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maDon': maDon,
      'tenShipper': tenShipper,
      'soTienCod': soTienCod,
      'isCompleted': isCompleted,
      'ngayGiao': ngayGiao,
    };
  }

  CodModel copyWith({
    String? id,
    String? maDon,
    String? tenShipper,
    double? soTienCod,
    bool? isCompleted,
    String? ngayGiao,
  }) {
    return CodModel(
      id: id ?? this.id,
      maDon: maDon ?? this.maDon,
      tenShipper: tenShipper ?? this.tenShipper,
      soTienCod: soTienCod ?? this.soTienCod,
      isCompleted: isCompleted ?? this.isCompleted,
      ngayGiao: ngayGiao ?? this.ngayGiao,
    );
  }
}