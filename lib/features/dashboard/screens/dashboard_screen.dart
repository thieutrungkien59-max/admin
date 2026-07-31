import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:admin/models/don_hang_model.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _error;

  List<Marker> _markers = [];
  List<DonHangModel> _pendingOrders = [];
  int _pendingOrdersCount = 0;
  int _onlineShippersCount = 0;
  int _shippingOrdersCount = 0;
  int _codWarningsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Hàm phụ trợ bóc tách mảng an toàn từ dữ liệu API
  /// Tránh lỗi: TypeError: 0: type 'int' is not a subtype of type 'String' trên Web
  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    } else if (data is Map<String, dynamic>) {
      if (data.containsKey('danhSach') && data['danhSach'] is List) {
        return data['danhSach'] as List<dynamic>;
      }
      if (data.containsKey('data') && data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
    }
    return [];
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Gọi song song tất cả các API cần thiết cho Dashboard
      final results = await Future.wait([
        ApiService.getDonHangChoNhan(),      // [0] Danh sách đơn chờ
        ApiService.getDanhSachShipper(),     // [1] Danh sách shipper
        ApiService.getSoLuongDangGiao(),     // [2] Số lượng đơn đang giao
        ApiService.getSoLuongCanhBaoCod(),   // [3] Số lượng cảnh báo COD
      ]);

      if (!mounted) return;

      // Bóc tách mảng an toàn trước khi chuyển đổi Model
      final rawOrders = _extractList(results[0]);
      final orders = rawOrders
          .map((json) => DonHangModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final rawShippers = _extractList(results[1]);
      final shippers = rawShippers
          .map((json) => ShipperModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final int shippingCount = results[2] is int ? results[2] as int : 0;
      final int codWarningCount = results[3] is int ? results[3] as int : 0;

      final List<Marker> generatedMarkers = [];

      // Tạo Marker cho Đơn hàng
      for (var i = 0; i < orders.length; i++) {
        final order = orders[i];
        final lat = 10.7769 + (i * 0.004);
        final lng = 106.7009 + (i * 0.003);

        generatedMarkers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: Tooltip(
              message: 'Đơn: ${order.maDon}\nLấy: ${order.diemLayHang} -> Giao: ${order.diemGiaoHang}',
              child: GestureDetector(
                onTap: () => _showDetailDialog(
                  title: 'Thông tin đơn hàng #${order.maDon}',
                  content: 'Điểm lấy: ${order.diemLayHang}\nĐiểm giao: ${order.diemGiaoHang}\nTrạng thái: ${order.isUrgent ? "Gấp" : "Thường"}',
                ),
                child: Icon(
                  Icons.location_on,
                  color: order.isUrgent ? Colors.red : Colors.orange,
                  size: 38,
                ),
              ),
            ),
          ),
        );
      }

      // Tạo Marker cho Shipper
      for (var shipper in shippers) {
        generatedMarkers.add(
          Marker(
            point: LatLng(shipper.lat, shipper.lng),
            width: 40,
            height: 40,
            child: Tooltip(
              message: 'Shipper: ${shipper.hoTen}\n${shipper.bienSo} | Status: ${shipper.isOnline ? "Online" : "Offline"}',
              child: GestureDetector(
                onTap: () => _showShipperActionSheet(shipper),
                child: Icon(
                  Icons.directions_bike,
                  color: shipper.isOnline ? Colors.green : Colors.grey,
                  size: 34,
                ),
              ),
            ),
          ),
        );
      }

      setState(() {
        _markers = generatedMarkers;
        _pendingOrders = orders;
        _pendingOrdersCount = orders.length;
        _onlineShippersCount = shippers.where((s) => s.isOnline).length;
        _shippingOrdersCount = shippingCount;
        _codWarningsCount = codWarningCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showDetailDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showShipperActionSheet(ShipperModel shipper) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipper: ${shipper.hoTen}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Biển số: ${shipper.bienSo}'),
            Text('Trạng thái: ${shipper.isOnline ? "Hoạt động (Online)" : "Nghỉ (Offline)"}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Quản Lý'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Tải lại dữ liệu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Đã xảy ra lỗi: $_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDashboardData,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Các ô thống kê nhanh
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          _buildStatCard('Đơn chờ', '$_pendingOrdersCount', Colors.orange),
                          _buildStatCard('Đang giao', '$_shippingOrdersCount', Colors.blue),
                          _buildStatCard('Shipper', '$_onlineShippersCount', Colors.green),
                          _buildStatCard('Cảnh báo COD', '$_codWarningsCount', Colors.red),
                        ],
                      ),
                    ),
                    // Bản đồ khu vực
                    Expanded(
                      child: FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(10.7769, 106.7009), // TP.HCM
                          initialZoom: 13.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(markers: _markers),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}