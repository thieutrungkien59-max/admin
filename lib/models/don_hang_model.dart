class DonHangModel {
  final String id;
  final String maDon;
  final String thoiGianCho;
  final double trongLuong;
  final String kichThuoc;
  final double dungTich;
  final String tinhChat; // Ví dụ: "DỄ VỠ", "CỒNG KỀNH"
  final String diemLayHang;
  final String lienHeLayHang;
  final String diemGiaoHang;
  final String lienHeGiaoHang;
  final int duKienGiaoPhut;
  final String giaCuoc;
  final String hinhThucGiao; // Ví dụ: "Giao hỏa tốc"
  final String tienCod;
  final double quangDuongKm;
  final bool isUrgent; // Cần điều phối thủ công (>5 phút)

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
}