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

  /// Lấy các đơn vẫn đang hoạt động trên hệ thống Admin.
  ///
  /// Bao gồm:
  /// - ChoXacNhan
  /// - ChoShipperXacNhan
  /// - DaXacNhan
  /// - DangGiao
  /// - DangVanChuyen
  static Future<List<dynamic>> getDonHangDangHoatDong() async {
    final response = await http.get(
      Uri.parse('$baseUrl/DonHang/danh-sach-dang-hoat-dong'),
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

  /// Admin chỉ định đơn cho Shipper.
  ///
  /// Thành công:
  /// - trả true.
  ///
  /// Thất bại:
  /// - KHÔNG nuốt lỗi bằng `return false`;
  /// - throw Exception với đúng `message` backend để UI hiển thị Snackbar.
  static Future<bool> phanDon(String maDon, String shipperId) async {
    final url = Uri.parse('$baseUrl/DonHang/admin-phan-don');

    final payload = <String, dynamic>{
      'maDonHang': maDon.trim(),
      'maShipper': shipperId.trim(),
    };

    print('[ADMIN_PHAN_DON] POST $url');
    print('[ADMIN_PHAN_DON] payload = ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );

      print(
        '[ADMIN_PHAN_DON] status=${response.statusCode} '
        'body=${response.body}',
      );

      Map<String, dynamic>? decoded;

      try {
        final raw = jsonDecode(response.body);

        if (raw is Map) {
          decoded = Map<String, dynamic>.from(raw);
        }
      } catch (_) {
        // Nếu backend không trả JSON thì giữ raw body ở bên dưới.
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      final backendMessage = decoded?['message']?.toString().trim();

      throw Exception(
        backendMessage != null && backendMessage.isNotEmpty
            ? backendMessage
            : 'Chỉ định Shipper thất bại '
                  '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      // Giữ Exception backend để DispatchCenter hiển thị đúng message.
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Không thể gọi API chỉ định Shipper: $e');
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
      Uri.parse('$baseUrl/DonHang/chi-tiet/$maDh'),
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

  /// Admin tạo đơn hộ khách vãng lai hoặc khách có tài khoản.
  static Future<Map<String, dynamic>> adminTaoDon(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DonHang/admin-tao-don'),
      headers: _headers,
      body: json.encode(data),
    );

    Map<String, dynamic>? decoded;

    try {
      final raw = json.decode(response.body);
      if (raw is Map) {
        decoded = Map<String, dynamic>.from(raw);
      }
    } catch (_) {}

    if (response.statusCode == 200 || response.statusCode == 201) {
      return decoded ?? <String, dynamic>{};
    }

    final message = decoded?['message']?.toString().trim();

    throw Exception(
      message != null && message.isNotEmpty
          ? message
          : 'Tạo đơn thất bại (${response.statusCode}): ${response.body}',
    );
  }

  /// Admin cập nhật đơn chưa được phân Shipper.
  ///
  /// Backend sẽ tự tính lại route/ETA/phí từ tọa độ.
  static Future<Map<String, dynamic>> adminCapNhatDon(
    String maDh,
    Map<String, dynamic> data,
  ) async {
    final orderId = maDh.trim();

    if (orderId.isEmpty) {
      throw Exception('Mã đơn hàng không hợp lệ.');
    }

    final response = await http.put(
      Uri.parse(
        '$baseUrl/DonHang/admin-cap-nhat-don/${Uri.encodeComponent(orderId)}',
      ),
      headers: _headers,
      body: json.encode(data),
    );

    Map<String, dynamic>? decoded;

    try {
      final raw = json.decode(response.body);
      if (raw is Map) {
        decoded = Map<String, dynamic>.from(raw);
      }
    } catch (_) {}

    if (response.statusCode == 200 || response.statusCode == 204) {
      return decoded ?? <String, dynamic>{};
    }

    final message = decoded?['message']?.toString().trim();

    throw Exception(
      message != null && message.isNotEmpty
          ? message
          : 'Cập nhật đơn thất bại '
                '(${response.statusCode}): ${response.body}',
    );
  }

  /// Admin xóa đơn chưa được phân Shipper.
  ///
  /// Backend chỉ cho phép:
  /// - trangThai = ChoXacNhan
  /// - maSp = null/rỗng
  static Future<void> adminXoaDon(String maDh) async {
    final orderId = maDh.trim();

    if (orderId.isEmpty) {
      throw Exception('Mã đơn hàng không hợp lệ.');
    }

    final response = await http.delete(
      Uri.parse(
        '$baseUrl/DonHang/admin-xoa-don/${Uri.encodeComponent(orderId)}',
      ),
      headers: _headers,
    );

    Map<String, dynamic>? decoded;

    try {
      final raw = json.decode(response.body);
      if (raw is Map) {
        decoded = Map<String, dynamic>.from(raw);
      }
    } catch (_) {}

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final message = decoded?['message']?.toString().trim();

    throw Exception(
      message != null && message.isNotEmpty
          ? message
          : 'Xóa đơn thất bại (${response.statusCode}): ${response.body}',
    );
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
      Uri.parse('$baseUrl/Shipper/danh-sach-toan-bo'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  /// Đổi trạng thái hoạt động shipper
  static Future<bool> doiTrangThaiHoatDongShipper(
    Map<String, dynamic> data,
  ) async {
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
      'maShipper': maShipper,
      'trangThaiMoi': 'NgoaiTuyen',
    });
  }

  /// Lấy thông tin chi tiết hồ sơ shipper để phê duyệt
  static Future<Map<String, dynamic>> getChiTietShipper(
    String shipperId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Auth/profile/$shipperId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      // Bóc tách 'chiTiet' ra luôn để màn hình AppoveShipper dễ lấy hoTen, cccd...
      return (decodedData['chiTiet'] ?? decodedData) as Map<String, dynamic>;
    } else {
      throw Exception('Không thể lấy chi tiết hồ sơ ($shipperId)');
    }
  }

  /// Duyệt hồ sơ Shipper (Giữ named params để khớp giao diện)
  static Future<void> duyetHoSoShipper({
    required String maShipper,
    required bool isApproved,
  }) async {
    // Đã xóa chữ /api dư thừa trong đường dẫn
    final url = Uri.parse('$baseUrl/Shipper/phe-duyet/$maShipper');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'isApproved': isApproved}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Thao tác phê duyệt thất bại');
    }
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
  static Future<Map<String, dynamic>> getBangLuongShipper(
    String maShipper,
  ) async {
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

  /// Duyệt phiếu đối soát COD.
  /// data cần có: maDs, maNguoiDuyet, hanhDong = DaDuyet.
  static Future<bool> duyetPhieuDoiSoat(Map<String, dynamic> data) async {
    final maDs = data['maDs']?.toString().trim();

    if (maDs == null || maDs.isEmpty) {
      throw Exception('Thiếu mã phiếu đối soát.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/DoiSoat/duyet-phieu/$maDs'),
      headers: _headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return true;
    }

    String message = response.body;

    try {
      final decoded = json.decode(response.body);

      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {
      // Giữ nguyên response.body nếu backend không trả JSON.
    }

    throw Exception(message);
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    String message = response.body;

    try {
      final decoded = json.decode(response.body);

      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      } else if (decoded is Map && decoded['errors'] != null) {
        message = decoded['errors'].toString();
      }
    } catch (_) {
      // Giữ raw body nếu backend không trả JSON.
    }

    throw Exception('Lưu cấu hình thất bại (${response.statusCode}): $message');
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

  /// Thêm/cập nhật một tham số hệ thống.
  static Future<bool> updateThamSoHeThong({
    required String maThamSo,
    required String giaTri,
    String? moTa,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/SystemConfig/cap-nhat-tham-so'),
      headers: _headers,
      body: json.encode({'maThamSo': maThamSo, 'giaTri': giaTri, 'moTa': moTa}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception(
      'Lỗi cập nhật tham số $maThamSo '
      '(${response.statusCode}): ${response.body}',
    );
  }

  /// Lấy tuyến đường + km + phí từ cùng endpoint backend mà Customer sử dụng.
  static Future<ShippingRouteData> getShippingRoute({
    required double pickupLat,
    required double pickupLng,
    required double deliveryLat,
    required double deliveryLng,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/DonHang/tinh-phi-van-chuyen'),
      headers: _headers,
      body: json.encode({
        'viDoLay': pickupLat,
        'kinhDoLay': pickupLng,
        'viDoGiao': deliveryLat,
        'kinhDoGiao': deliveryLng,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Không lấy được tuyến đường '
        '(${response.statusCode}): ${response.body}',
      );
    }

    return ShippingRouteData.fromJson(
      Map<String, dynamic>.from(json.decode(response.body) as Map),
    );
  }

  // ==========================================
  // HÀM BỔ TRỢ XỬ LÝ RESPONSE (Helper Methods)
  // ==========================================

  static List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is List) {
        return decoded;
      }
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('danhSach') && decoded['danhSach'] is List) {
          return decoded['danhSach'] as List<dynamic>;
        }
        if (decoded.containsKey('data') && decoded['data'] is List) {
          return decoded['data'] as List<dynamic>;
        }
      }
      return [];
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
    double asDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

    final points = <ShippingRoutePoint>[];
    final rawPoints = json['routePoints'];

    if (rawPoints is List) {
      for (final item in rawPoints) {
        if (item is! Map) continue;

        final map = Map<String, dynamic>.from(item);
        points.add(
          ShippingRoutePoint(
            latitude: asDouble(map['latitude'] ?? map['Latitude']),
            longitude: asDouble(map['longitude'] ?? map['Longitude']),
          ),
        );
      }
    }

    return ShippingRouteData(
      distanceKm: asDouble(json['distanceKm']),
      durationMinutes: (json['durationMinutes'] is num)
          ? (json['durationMinutes'] as num).round()
          : int.tryParse('${json['durationMinutes']}') ?? 0,
      shippingFee: asDouble(json['shippingFee']),
      routePoints: points,
    );
  }
}

class ShipperPickupRouteData {
  const ShipperPickupRouteData({
    required this.distanceKm,
    required this.durationMinutes,
  });

  final double distanceKm;
  final double durationMinutes;
}

class OsrmService {
  /// Tính route đường bộ từ GPS hiện tại của Shipper tới điểm lấy hàng.
  static Future<ShipperPickupRouteData?> getShipperToPickupRoute({
    required double shipperLat,
    required double shipperLng,
    required double pickupLat,
    required double pickupLng,
  }) async {
    final String url =
        'https://router.project-osrm.org/route/v1/driving/'
        '$shipperLng,$shipperLat;$pickupLng,$pickupLat'
        '?overview=false&steps=false';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: const {'User-Agent': 'LogiRoute-Admin-App/1.0'},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);

      if (data is! Map ||
          data['routes'] is! List ||
          (data['routes'] as List).isEmpty) {
        return null;
      }

      final route = Map<String, dynamic>.from(
        (data['routes'] as List).first as Map,
      );

      final distanceMeters = (route['distance'] as num?)?.toDouble();
      final durationSeconds = (route['duration'] as num?)?.toDouble();

      if (distanceMeters == null || durationSeconds == null) {
        return null;
      }

      return ShipperPickupRouteData(
        distanceKm: double.parse((distanceMeters / 1000).toStringAsFixed(1)),
        durationMinutes: double.parse(
          (durationSeconds / 60).toStringAsFixed(1),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Hàm lấy khoảng cách thực tế (Đường bộ) từ OSRM
  /// Trả về một Map chứa: 'distance' (km) và 'duration' (phút)
  static Future<Map<String, double>> getRealRouting(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    // ⚠️ LƯU Ý CỰC KỲ QUAN TRỌNG:
    // OSRM bắt buộc truyền tọa độ theo thứ tự: KINH ĐỘ (Lng) phẩy VĨ ĐỘ (Lat)
    final String url =
        'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$endLng,$endLat?overview=false';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kiểm tra xem có tìm được đường đi không
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];

          // OSRM trả về khoảng cách bằng MÉT -> chia 1000 ra KM
          final distanceKm = route['distance'] / 1000.0;

          // OSRM trả về thời gian bằng GIÂY -> chia 60 ra PHÚT
          final durationMin = route['duration'] / 60.0;

          return {
            'distance': double.parse(
              distanceKm.toStringAsFixed(1),
            ), // Làm tròn 1 chữ số thập phân
            'duration': double.parse(durationMin.toStringAsFixed(1)),
          };
        }
      }
    } catch (e) {
      print('Lỗi gọi API OSRM: $e');
    }

    // Nếu lỗi hoặc không tìm thấy đường thì trả về 0
    return {'distance': 0.0, 'duration': 0.0};
  }
}
