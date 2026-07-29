import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://startle-kilogram-greeting.ngrok-free.dev/api";

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "ngrok-skip-browser-warning": "true",
  };

  // ==========================================
  // 1. ĐƠN HÀNG (DonHang)
  // ==========================================

  /// Lấy danh sách đơn hàng chờ nhận
  static Future<List<dynamic>> getDonHangChoNhan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/DonHang/danh-sach-cho-nhan'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  /// Lấy số lượng đơn hàng đang giao
  static Future<int> getSoLuongDangGiao() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DonHang/dang-giao/count'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      return 0;
    } catch (e) {
      print('Lỗi lấy số lượng đang giao: $e');
      return 0;
    }
  }

  /// Lấy đơn hàng theo mã khách hàng
  static Future<List<dynamic>> getDonHangByKhachHang(String maKh) async {
    final response = await http.get(
      Uri.parse('$baseUrl/DonHang/khach-hang/$maKh'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  /// Lấy đơn hàng theo mã shipper
  static Future<List<dynamic>> getDonHangByShipper(String maSp) async {
    final response = await http.get(
      Uri.parse('$baseUrl/DonHang/shipper/$maSp'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  /// Lấy chi tiết 1 đơn hàng theo mã đơn hàng
  static Future<Map<String, dynamic>> getChiTietDonHang(String maDh) async {
    final response = await http.get(
      Uri.parse('$baseUrl/DonHang/$maDh'),
      headers: _headers,
    );
    return _handleMapResponse(response);
  }

  /// Tạo đơn hàng mới
  static Future<bool> taoDonMoi(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DonHang/tao-don-moi'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Cập nhật trạng thái đơn hàng
  static Future<bool> capNhatTrangThaiDonHang(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DonHang/cap-nhat-trang-thai'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  /// Báo giao thất bại
  static Future<bool> baoGiaoThatBai(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DonHang/bao-giao-that-bai'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  /// Upload minh chứng giao hàng
  static Future<bool> uploadMinhChung(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DonHang/upload-minh-chung'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  // ==========================================
  // 2. SHIPPER
  // ==========================================

  /// Lấy danh sách hồ sơ shipper chờ duyệt
  static Future<List<dynamic>> getShipperChoDuyet() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Shipper/danh-sach-cho-duyet'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  /// Lấy danh sách shipper đang online/hoạt động
  static Future<List<dynamic>> getDanhSachShipper() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Shipper/danh-sach-online'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  /// Phân đơn cho shipper
  static Future<bool> phanDon(String maDon, String shipperId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Shipper/ban-giao-don'),
        headers: _headers,
        body: jsonEncode({
          'maDh': maDon,
          'maSp': shipperId,
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Lỗi phân đơn: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi gọi API phân đơn: $e');
      return false;
    }
  }

  /// Đổi trạng thái hoạt động shipper
  static Future<bool> doiTrangThaiHoatDongShipper(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Shipper/doi-trang-thai-hoat-dong'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  /// Ép tài xế ngoại tuyến (Hỗ trợ gọi nhanh từ nút trên Dashboard)
  static Future<bool> forceOffline(String maShipper) async {
    return await doiTrangThaiHoatDongShipper({
      'maSp': maShipper,
      'isOnline': false, // offline
    });
  }

  /// Duyệt hồ sơ shipper
  static Future<bool> duyetHoSoShipper(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Shipper/duyet-ho-so'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  /// Cập nhật vị trí GPS
  static Future<bool> capNhatGpsShipper(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Shipper/cap-nhat-gps'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  // ==========================================
  // 3. ĐỐI SOÁT (DoiSoat)
  // ==========================================

  /// Lấy ví COD của shipper
  static Future<Map<String, dynamic>> getViCodShipper(String maShipper) async {
    final response = await http.get(
      Uri.parse('$baseUrl/DoiSoat/vi-cod/$maShipper'),
      headers: _headers,
    );
    return _handleMapResponse(response);
  }

  /// Lấy số lượng cảnh báo COD
  static Future<int> getSoLuongCanhBaoCod() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/canhbao/cod/count'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      return 0;
    } catch (e) {
      print('Lỗi lấy cảnh báo COD: $e');
      return 0;
    }
  }

  /// Lấy danh sách phiếu đối soát chờ duyệt
  static Future<List<dynamic>> getDanhSachPhieuChoDuyet() async {
    final response = await http.get(
      Uri.parse('$baseUrl/DoiSoat/danh-sach-phieu-cho-duyet'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  /// Lấy bảng lương của shipper
  static Future<Map<String, dynamic>> getBangLuongShipper(String maShipper) async {
    final response = await http.get(
      Uri.parse('$baseUrl/DoiSoat/bang-luong/$maShipper'),
      headers: _headers,
    );
    return _handleMapResponse(response);
  }

  /// Tạo phiếu đối soát
  static Future<bool> taoPhieuDoiSoat(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DoiSoat/tao-phieu'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Duyệt phiếu đối soát
  static Future<bool> duyetPhieuDoiSoat(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DoiSoat/duyet-phieu'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  // ==========================================
  // 4. CẤU HÌNH HỆ THỐNG (SystemConfig)
  // ==========================================

  /// Lấy thông tin giờ cao điểm
  static Future<dynamic> getGioCaoDiem() async {
    final response = await http.get(
      Uri.parse('$baseUrl/SystemConfig/gio-cao-diem'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Lỗi lấy thông tin giờ cao điểm');
  }

  /// Cập nhật giờ cao điểm
  static Future<bool> updateGioCaoDiem(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/SystemConfig/gio-cao-diem'),
      headers: _headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  /// Lấy tham số hệ thống
  static Future<dynamic> getThamSoHeThong() async {
    final response = await http.get(
      Uri.parse('$baseUrl/SystemConfig/tham-so'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Lỗi lấy tham số hệ thống');
  }

  // ==========================================
  // HÀM BỔ TRỢ XỬ LÝ RESPONSE (Helper Methods)
  // ==========================================

  static List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Lỗi API (${response.statusCode}): ${response.body}');
    }
  }

  static Map<String, dynamic> _handleMapResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Lỗi API (${response.statusCode}): ${response.body}');
    }
  }
}