class CauHinhGioCaoDiemModel {
  final String maCd;
  final String gioBatDau;
  final String gioKetThuc;
  final double heSoPhi;
  final String? moTa;

  CauHinhGioCaoDiemModel({
    required this.maCd,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.heSoPhi,
    this.moTa,
  });

  factory CauHinhGioCaoDiemModel.fromJson(Map<String, dynamic> json) {
    return CauHinhGioCaoDiemModel(
      maCd: json['maCd'] ?? json['MaCd'] ?? 'CD01',
      gioBatDau: json['gioBatDau'] ?? json['GioBatDau'] ?? '07:30:00',
      gioKetThuc: json['gioKetThuc'] ?? json['GioKetThuc'] ?? '19:00:00',
      heSoPhi: (json['heSoPhi'] ?? json['HeSoPhi'] ?? json['heSoPhuPhi'] ?? 1.5).toDouble(),
      moTa: json['moTa'] ?? json['MoTa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maCd': maCd,
      'gioBatDau': gioBatDau,
      'gioKetThuc': gioKetThuc,
      'heSoPhi': heSoPhi,
      'moTa': moTa ?? 'Khung giờ cao điểm áp dụng phụ phí',
    };
  }
}