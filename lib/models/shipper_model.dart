class ShipperModel {
  final String id;
  final String hoTen;
  final String bienSo;
  final double danhGia;
  final int soDonDaGiao;
  final double khoangCachKm;
  final int thoiGianRanhPhut;
  final bool isOptimal; // Nhãn "TỐI ƯU NHẤT"
  final bool isOnline;  // Khả dụng / Không khả dụng
  final String? lyDoKhongKhaDung;

  ShipperModel({
    required this.id,
    required this.hoTen,
    required this.bienSo,
    required this.danhGia,
    required this.soDonDaGiao,
    required this.khoangCachKm,
    required this.thoiGianRanhPhut,
    this.isOptimal = false,
    this.isOnline = true,
    this.lyDoKhongKhaDung,
  });
}