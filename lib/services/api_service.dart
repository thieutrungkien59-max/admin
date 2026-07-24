import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.8:5262/api";

  // 1. Lấy danh sách đơn hàng
  static Future<List<dynamic>> getDanhSachDonHang() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/DonHang'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi tải danh sách đơn hàng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến Server: $e');
    }
  }

  // 2. Tạo đơn hàng mới (POST)
  static Future<bool> taoDonHang(Map<String, dynamic> dataDonHang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/DonHang'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(dataDonHang),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. Lấy danh sách Shipper (Đã sửa lại khớp với Controller C# Shippers / ViTriShipper)
  static Future<List<dynamic>> getDanhSachShipper() async {
    try {
      // Sửa thành 'Shippers' hoặc 'ViTriShipper/all-shippers' tùy theo Controller bên C#
      final response = await http.get(Uri.parse('$baseUrl/Shipper')); 
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi lấy danh sách shipper: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến Server: $e');
    }
  }

  // 4. Lấy dữ liệu đối soát COD (Đã sửa 'CodReconciliation' thành 'DoiSoat')
  static Future<List<dynamic>> getDanhSachCod() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/DoiSoat')); // 👈 Đã sửa lại đúng route bên C#
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi lấy dữ liệu đối soát COD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến Server: $e');
    }
  }
}