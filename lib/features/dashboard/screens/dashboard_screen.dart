import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import 'package:admin/models/don_hang_model.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MapController _mapController = MapController();
  static const LatLng _centerLocation = LatLng(10.7769, 106.7009);

  List<Marker> _markers = [];
  bool _isLoading = true;
  String? _error;

  // Biến lưu trữ số liệu từ API
  int _pendingOrdersCount = 0;
  int _shippingOrdersCount = 0;
  int _onlineShippersCount = 0;
  int _codWarningsCount = 0;

  //lưu lại danh sách đơn chờ để làm data cho Dropdown phân đơn
  List<DonHangModel> _pendingOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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

      final orders = (results[0] as List)
          .map((json) => DonHangModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final shippers = (results[1] as List)
          .map((json) => ShipperModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final int shippingCount = results[2] as int;
      final int codWarningCount = results[3] as int;

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
        _pendingOrders = orders; // Lưu danh sách đơn chờ cho Dropdown
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

  void _showShipperActionSheet(ShipperModel shipper) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: Colors.blue, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipper.hoTen,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Biển số: ${shipper.bienSo}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: shipper.isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              shipper.isOnline ? 'Đang hoạt động' : 'Ngoại tuyến',
                              style: TextStyle(
                                  color: shipper.isOnline ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              // Nút Phân đơn
              ListTile(
                leading: const Icon(Icons.assignment_ind, color: Colors.blue),
                title: const Text('Phân đơn cho tài xế này'),
                enabled: shipper.isOnline,
                onTap: () {
                  Navigator.pop(context);
                  _phanDonChoShipper(shipper);
                },
              ),

              // Nút Gọi điện
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Gọi điện liên hệ'),
                onTap: () async {
                  Navigator.pop(context);

                  final Uri callUri = Uri.parse('tel:${shipper.soDienThoai}');

                  try {
                    if (await canLaunchUrl(callUri)) {
                      await launchUrl(callUri);
                    } else {
                      // khi máy ko có SIM thì thông báo lỗi
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thiết bị của bạn không hỗ trợ gọi điện!')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi khi mở trình gọi điện: $e')),
                      );
                    }
                  }
                },
              ),

              // 4. Nút Ép ngoại tuyến
              ListTile(
                leading: const Icon(Icons.power_settings_new, color: Colors.red),
                title: const Text('Ép tài xế ngoại tuyến', style: TextStyle(color: Colors.red)),
                enabled: shipper.isOnline,
                onTap: () {
                  Navigator.pop(context);
                  _xacNhanEpNgoaiTuyen(shipper);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _phanDonChoShipper(ShipperModel shipper) {
    if (_pendingOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hiện không có đơn hàng nào đang chờ phân!')),
      );
      return;
    }

    String? selectedMaDon;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Phân đơn cho ${shipper.hoTen}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vui lòng chọn đơn hàng cần giao:'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('Chọn mã đơn hàng...'),
                    value: selectedMaDon,
                    items: _pendingOrders.map((order) {
                      return DropdownMenuItem<String>(
                        value: order.maDon,
                        child: Text('${order.maDon} - ${order.isUrgent ? "(Gấp)" : ""}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedMaDon = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: selectedMaDon == null
                      ? null
                      : () async {
                          Navigator.pop(context);
                          
                          // gọi ApiService để phân đơn
                          await ApiService.phanDon(selectedMaDon!, shipper.id);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã phân đơn $selectedMaDon cho ${shipper.hoTen}')),
                          );
                          
                          _loadDashboardData(); 
                        },
                  child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _xacNhanEpNgoaiTuyen(ShipperModel shipper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cảnh báo'),
        content: Text('Bạn có chắc chắn muốn ép tài xế ${shipper.hoTen} ngoại tuyến không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); 
              
              // TODO: Chỗ này gọi API set offline
              // await ApiService.forceOffline(shipper.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã chuyển ${shipper.hoTen} sang ngoại tuyến')),
              );
              _loadDashboardData(); // Cập nhật lại bản đồ
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề & nút Tải lại
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tổng quan vận hành hôm nay',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Tải lại bản đồ & số liệu',
              onPressed: _loadDashboardData,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Thẻ thống kê
        Row(
          children: [
            _buildStatCard('Tổng đơn chờ', _isLoading ? '...' : '$_pendingOrdersCount', Icons.inventory_2, Colors.blue),
            const SizedBox(width: 20),
            _buildStatCard('Đang giao', _isLoading ? '...' : '$_shippingOrdersCount', Icons.local_shipping, AppColors.statusOrange),
            const SizedBox(width: 20),
            _buildStatCard('Tài xế Online', _isLoading ? '...' : '$_onlineShippersCount', Icons.motorcycle, AppColors.statusGreen),
            const SizedBox(width: 20),
            _buildStatCard('Cảnh báo COD', _isLoading ? '...' : '$_codWarningsCount', Icons.warning_amber_rounded, AppColors.statusRed),
          ],
        ),
        const SizedBox(height: 30),

        // Khung hiển thị Bản đồ
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadDashboardData,
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
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textSubtitle, fontSize: 14)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}