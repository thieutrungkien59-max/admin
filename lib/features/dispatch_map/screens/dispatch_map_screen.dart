import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:admin/models/don_hang_model.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/services/api_service.dart';

class DispatchMapScreen extends StatefulWidget {
  const DispatchMapScreen({super.key});

  @override
  State<DispatchMapScreen> createState() => _DispatchMapScreenState();
}

class _DispatchMapScreenState extends State<DispatchMapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _centerLocation = LatLng(10.7769, 106.7009);

  List<Marker> _markers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMapDataFromApi();
  }

  Future<void> _loadMapDataFromApi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getDanhSachDonHang(),
        ApiService.getDanhSachShipper(),
      ]);

      final orders = (results[0] as List)
          .map((json) => DonHangModel.fromJson(json as Map<String, dynamic>))
          .toList();
      final shippers = (results[1] as List)
          .map((json) => ShipperModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final List<Marker> generatedMarkers = [];

      // 1. Tạo Marker cho Đơn hàng
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

      // 2. Tạo Marker cho Shipper
      for (var shipper in shippers) {
        generatedMarkers.add(
          Marker(
            point: LatLng(shipper.lat, shipper.lng),
            width: 40,
            height: 40,
            child: Tooltip(
              message: 'Shipper: ${shipper.hoTen}\n${shipper.bienSo} | Status: ${shipper.isOnline ? "Online" : "Offline"}',
              child: GestureDetector(
                onTap: () => _showDetailDialog(
                  title: 'Shipper: ${shipper.hoTen}',
                  content: 'Biển số: ${shipper.bienSo}\nTrạng thái: ${shipper.isOnline ? "Hoạt động" : "Ngoại tuyến"}',
                ),
                child: Icon(
                  Icons.directions_bike,
                  color: shipper.isOnline ? Colors.green : Colors.blue,
                  size: 34,
                ),
              ),
            ),
          ),
        );
      }

      setState(() {
        _markers = generatedMarkers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Hàm hiển thị hộp thoại thông tin khi click vào Marker
  void _showDetailDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadMapDataFromApi,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: _centerLocation,
                        initialZoom: 13.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.admin.lougiroute',
                        ),
                        MarkerLayer(
                          markers: _markers,
                        ),
                      ],
                    ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.map, color: Color(0xFFD32F2F)),
                        const SizedBox(width: 8),
                        Text(
                          'Bản đồ Điều phối (${_markers.length} điểm)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Tải lại bản đồ',
                      onPressed: _loadMapDataFromApi,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}