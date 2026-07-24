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
      maDon: json['maDon'] ?? json['MaDon'] ?? 'N/A',
      tenShipper: json['tenShipper'] ?? json['TenShipper'] ?? 'N/A',
      soTienCod: ((json['soTienCod'] ?? json['SoTienCod'] ?? 0) as num).toDouble(),
      isCompleted: json['isCompleted'] ?? json['IsCompleted'] ?? (json['trangThai'] == 'DA_DOI_SOAT'),
      ngayGiao: json['ngayGiao'] ?? json['NgayGiao'] ?? 'N/A',
    );
  }
}