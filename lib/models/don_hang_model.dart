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
      maDon: json['maDon'] ?? json['MaDon'] ?? '#ORD-UNKNOWN',
      thoiGianCho: json['thoiGianCho'] ?? json['ThoiGianCho'] ?? '00:00',
      trongLuong: ((json['trongLuong'] ?? json['TrongLuong'] ?? 0) as num).toDouble(),
      kichThuoc: json['kichThuoc'] ?? json['KichThuoc'] ?? 'N/A',
      dungTich: ((json['dungTich'] ?? json['DungTich'] ?? 0) as num).toDouble(),
      tinhChat: json['tinhChat'] ?? json['TinhChat'] ?? 'THƯỜNG',
      diemLayHang: json['diemLayHang'] ?? json['DiemLayHang'] ?? '',
      lienHeLayHang: json['lienHeLayHang'] ?? json['LienHeLayHang'] ?? '',
      diemGiaoHang: json['diemGiaoHang'] ?? json['DiemGiaoHang'] ?? '',
      lienHeGiaoHang: json['lienHeGiaoHang'] ?? json['LienHeGiaoHang'] ?? '',
      duKienGiaoPhut: json['duKienGiaoPhut'] ?? json['DuKienGiaoPhut'] ?? 0,
      giaCuoc: json['giaCuoc'] ?? json['GiaCuoc'] ?? '0đ',
      hinhThucGiao: json['hinhThucGiao'] ?? json['HinhThucGiao'] ?? 'Tiêu chuẩn',
      tienCod: json['tienCod'] ?? json['TienCod'] ?? '0đ',
      quangDuongKm: ((json['quangDuongKm'] ?? json['QuangDuongKm'] ?? 0) as num).toDouble(),
      isUrgent: json['isUrgent'] ?? json['IsUrgent'] ?? false,
    );
  }
}