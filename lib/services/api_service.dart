import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://startle-kilogram-greeting.ngrok-free.dev/api";

  static String? _token;

  // Lấy header kèm token nếu đã đăng nhập
  static Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
        if (_token != null) "Authorization": "Bearer $_token",
      };

  static void setToken(String token) {
    _token = token;
  }

  // ==========================================
  // 0. AUTH (Đăng nhập)
  // ==========================================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/identity/login'),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['accessToken'];

      // THÊM DÒNG NÀY ĐỂ IN TOKEN RA CONSOLE:
      print('====== TOKEN CỦA TUI NÈ ======');
      print(_token);
      print('================================');
      
      return data;
    }
    
    throw Exception('Đăng nhập thất bại. Vui lòng kiểm tra lại Email/Mật khẩu.');
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/identity/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Không thể lấy thông tin user (${response.statusCode})');
  }

  // ==========================================
  // 1. ORDER & DELIVERY (Đơn hàng & Điều phối)
  // ==========================================

  static Future<List<dynamic>> getDonHangChoNhan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/order?status=PENDING'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  static Future<List<dynamic>> getDonHangDangHoatDong() async {
    final response = await http.get(
      Uri.parse('$baseUrl/order?status=ACTIVE'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  static Future<List<dynamic>> getDonHangQuanLy() async {
    final response = await http.get(
      Uri.parse('$baseUrl/order'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  static Future<int> getSoLuongDangGiao() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/order/count?status=DELIVERING'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> phanDon(String maDon, String shipperId) async {
    final url = Uri.parse('$baseUrl/delivery/assign');
    final payload = <String, dynamic>{
      'orderId': maDon.trim(),
      'shipperId': shipperId.trim(),
    };

    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(payload));
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw Exception('Chỉ định Shipper thất bại: ${response.body}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi gọi API: $e');
    }
  }

  static Future<List<dynamic>> getDonHangByKhachHang(String maKh) async {
    final response = await http.get(Uri.parse('$baseUrl/order?customerId=$maKh'), headers: _headers);
    return _handleListResponse(response);
  }

  static Future<List<dynamic>> getDonHangByShipper(String maSp) async {
    final response = await http.get(Uri.parse('$baseUrl/order?shipperId=$maSp'), headers: _headers);
    return _handleListResponse(response);
  }

  static Future<Map<String, dynamic>> getChiTietDonHang(String maDh) async {
    final response = await http.get(Uri.parse('$baseUrl/order/$maDh'), headers: _headers);
    return _handleMapResponse(response);
  }

  static Future<bool> taoDonMoi(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/order'), headers: _headers, body: json.encode(data));
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<Map<String, dynamic>> adminTaoDon(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/order'), headers: _headers, body: json.encode(data));
    if (response.statusCode == 200 || response.statusCode == 201) return json.decode(response.body);
    throw Exception('Tạo đơn thất bại (${response.statusCode})');
  }

  static Future<Map<String, dynamic>> adminCapNhatDon(String maDh, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/order/$maDh'), headers: _headers, body: json.encode(data));
    if (response.statusCode == 200 || response.statusCode == 204) return {};
    throw Exception('Cập nhật đơn thất bại (${response.statusCode})');
  }

  static Future<void> adminXoaDon(String maDh) async {
    final response = await http.delete(Uri.parse('$baseUrl/order/$maDh'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Xóa đơn thất bại (${response.statusCode})');
    }
  }

  static Future<bool> capNhatTrangThaiDonHang(Map<String, dynamic> data) async {
    final maDh = data['maDh'] ?? data['orderId'];
    final status = data['trangThai'] ?? data['status'];
    final response = await http.patch(Uri.parse('$baseUrl/order/$maDh/status'), headers: _headers, body: json.encode(status));
    return response.statusCode == 200;
  }

  static Future<bool> uploadMinhChung(Map<String, dynamic> data) async {
    final maDh = data['maDh'] ?? data['orderId'];
    final response = await http.post(Uri.parse('$baseUrl/delivery/$maDh/complete'), headers: _headers);
    return response.statusCode == 200;
  }

  static Future<bool> baoGiaoThatBai(Map<String, dynamic> data) async {
    data['status'] = 'FAILED';
    return await capNhatTrangThaiDonHang(data);
  }

  // ==========================================
  // 2. IDENTITY (Shipper)
  // ==========================================

  static Future<List<dynamic>> getShipperChoDuyet() async {
    final response = await http.get(Uri.parse('$baseUrl/identity/shippers?status=PENDING'), headers: _headers);
    return _handleListResponse(response);
  }

  static Future<List<dynamic>> getDanhSachShipper() async {
    final response = await http.get(Uri.parse('$baseUrl/identity/shippers'), headers: _headers);
    return _handleListResponse(response);
  }

  static Future<bool> doiTrangThaiHoatDongShipper(Map<String, dynamic> data) async {
    final maShipper = data['maShipper'];
    final response = await http.patch(
      Uri.parse('$baseUrl/identity/shippers/$maShipper/status'),
      headers: _headers,
      body: json.encode({'status': data['trangThaiMoi']}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> forceOffline(String maShipper) async {
    return await doiTrangThaiHoatDongShipper({'maShipper': maShipper, 'trangThaiMoi': 'OFFLINE'});
  }

  static Future<Map<String, dynamic>> getChiTietShipper(String shipperId) async {
    final response = await http.get(Uri.parse('$baseUrl/identity/users/$shipperId'), headers: _headers);
    return _handleMapResponse(response);
  }

  static Future<void> duyetHoSoShipper({required String maShipper, required bool isApproved}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/identity/shippers/$maShipper/approve'),
      headers: _headers,
      body: jsonEncode({'isApproved': isApproved}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) throw Exception('Thao tác phê duyệt thất bại');
  }

  static Future<bool> capNhatGpsShipper(Map<String, dynamic> data) async => true;

  // ==========================================
  // 3. FINANCE (Tài chính)
  // ==========================================

  static Future<Map<String, dynamic>> getViCodShipper(String maShipper) async {
    final response = await http.get(Uri.parse('$baseUrl/finance/wallet/$maShipper'), headers: _headers);
    return _handleMapResponse(response);
  }

  static Future<Map<String, dynamic>> getBangLuongShipper(String maShipper) async {
    final response = await http.get(Uri.parse('$baseUrl/finance/salary/$maShipper'), headers: _headers);
    return _handleMapResponse(response);
  }

  static Future<int> getSoLuongCanhBaoCod() async => 0;
  static Future<List<dynamic>> getDanhSachPhieuChoDuyet() async => [];
  static Future<bool> taoPhieuDoiSoat(Map<String, dynamic> data) async => true;
  static Future<bool> duyetPhieuDoiSoat(Map<String, dynamic> data) async => true;

  // ==========================================
  // 4. SYSTEM CONFIG (Cấu hình)
  // ==========================================
  
  static Future<dynamic> getGioCaoDiem() async {
    final response = await http.get(Uri.parse('$baseUrl/systemconfig/peak-hours'), headers: _headers);
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Lỗi lấy thông tin giờ cao điểm');
  }

  static Future<bool> updateGioCaoDiem(Map<String, dynamic> data) async => true;
  static Future<dynamic> getThamSoHeThong() async => {};
  static Future<bool> updateThamSoHeThong({required String maThamSo, required String giaTri, String? moTa}) async => true;

  static Future<ShippingRouteData> getShippingRoute({
    required double pickupLat, required double pickupLng, required double deliveryLat, required double deliveryLng,
  }) async {
    final osrmData = await OsrmService.getRealRouting(pickupLat, pickupLng, deliveryLat, deliveryLng);
    final distanceKm = osrmData['distance'] ?? 0.0;
    final durationMin = osrmData['duration']?.toInt() ?? 0;

    final response = await http.post(
      Uri.parse('$baseUrl/delivery/quote'),
      headers: _headers,
      body: json.encode({'DistanceKm': distanceKm}),
    );

    if (response.statusCode != 200) throw Exception('Lỗi tính phí ship');
    
    final quoteData = json.decode(response.body);
    return ShippingRouteData(
      distanceKm: distanceKm,
      durationMinutes: durationMin,
      shippingFee: (quoteData['shippingFee'] as num).toDouble(),
      routePoints: [],
    );
  }

  // ==========================================
  // HÀM BỔ TRỢ XỬ LÝ RESPONSE
  // ==========================================

  static List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map<String, dynamic> && decoded['data'] is List) return decoded['data'] as List<dynamic>;
      return [];
    }
    throw Exception('Lỗi API (${response.statusCode}): ${response.body}');
  }

  static Map<String, dynamic> _handleMapResponse(http.Response response) {
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    }
    throw Exception('Lỗi API (${response.statusCode}): ${response.body}');
  }
}

// ==========================================
// CÁC CLASS OSRM
// ==========================================

class ShippingRoutePoint {
  const ShippingRoutePoint({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

class ShippingRouteData {
  const ShippingRouteData({
    required this.distanceKm,
    required this.durationMinutes,
    required this.shippingFee,
    required this.routePoints,
  });

  final double distanceKm;
  final int durationMinutes;
  final double shippingFee;
  final List<ShippingRoutePoint> routePoints;

  factory ShippingRouteData.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    return ShippingRouteData(
      distanceKm: asDouble(json['distanceKm']),
      durationMinutes: (json['durationMinutes'] is num)
          ? (json['durationMinutes'] as num).round()
          : int.tryParse('${json['durationMinutes']}') ?? 0,
      shippingFee: asDouble(json['shippingFee']),
      routePoints: [],
    );
  }
}

class ShipperPickupRouteData {
  const ShipperPickupRouteData({required this.distanceKm, required this.durationMinutes});
  final double distanceKm;
  final double durationMinutes;
}

class OsrmService {
  static Future<ShipperPickupRouteData?> getShipperToPickupRoute({
    required double shipperLat, required double shipperLng, required double pickupLat, required double pickupLng,
  }) async {
    final String url = 'https://router.project-osrm.org/route/v1/driving/$shipperLng,$shipperLat;$pickupLng,$pickupLat?overview=false&steps=false';
    try {
      final response = await http.get(Uri.parse(url), headers: const {'User-Agent': 'LogiRoute-Admin-App/1.0'});
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body);
      if (data is! Map || data['routes'] is! List || (data['routes'] as List).isEmpty) return null;
      final route = Map<String, dynamic>.from((data['routes'] as List).first as Map);
      final distanceMeters = (route['distance'] as num?)?.toDouble();
      final durationSeconds = (route['duration'] as num?)?.toDouble();
      if (distanceMeters == null || durationSeconds == null) return null;
      return ShipperPickupRouteData(
        distanceKm: double.parse((distanceMeters / 1000).toStringAsFixed(1)),
        durationMinutes: double.parse((durationSeconds / 60).toStringAsFixed(1)),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, double>> getRealRouting(
    double startLat, double startLng, double endLat, double endLng,
  ) async {
    final String url = 'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$endLng,$endLat?overview=false';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          return {
            'distance': double.parse((route['distance'] / 1000.0).toStringAsFixed(1)),
            'duration': double.parse((route['duration'] / 60.0).toStringAsFixed(1)),
          };
        }
      }
    } catch (e) {
      print('Lỗi OSRM: $e');
    }
    return {'distance': 0.0, 'duration': 0.0};
  }
}