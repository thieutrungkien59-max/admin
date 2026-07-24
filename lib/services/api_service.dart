import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ QUAN TRỌNG: Thay cái IP này bằng IP mạng LAN của máy trùm (IPv4 từ lệnh ipconfig)
  static const String baseUrl = "http://192.168.1.8:5262/api";

  // Hàm lấy danh sách đơn hàng
  static Future<List<dynamic>> getDanhSachDonHang() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/DonHang'));
      
      if (response.statusCode == 200) {
        // Giải mã JSON nhận được từ C# Backend
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi tải dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến Server: $e');
    }
  }

  // Hàm tạo đơn hàng mới (POST)
  static Future<bool> taoDonHang(Map<String, dynamic> dataDonHang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/DonHang'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(dataDonHang),
      );

      return response.statusCode == 201; // Trả về true nếu tạo thành công (mã 201)
    } catch (e) {
      return false;
    }
  }
}