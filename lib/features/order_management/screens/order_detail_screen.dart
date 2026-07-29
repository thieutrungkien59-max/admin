import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:admin/services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _orderDetail;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 🟢 Gọi API lấy chi tiết đơn hàng theo ID
      final data = await ApiService.getChiTietDonHang(widget.orderId);

      if (!mounted) return;

      setState(() {
        _orderDetail = data;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        height: 300,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchOrderDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Lấy dữ liệu động từ API (fallback nếu không có)
    final maDon = _orderDetail?['maDon'] ?? widget.orderId;
    final thoiGianTao = _orderDetail?['thoiGianTao'] ?? 'N/A';
    final trangThai = _orderDetail?['trangThai'] ?? 'ĐANG XỬ LÝ';
    
    final nguoiGui = _orderDetail?['nguoiGui'] ?? {};
    final nguoiNhan = _orderDetail?['nguoiNhan'] ?? {};
    
    final khoiLuong = _orderDetail?['khoiLuong'] ?? '---';
    final kichThuoc = _orderDetail?['kichThuoc'] ?? '---';
    final tienCod = _orderDetail?['tienCod'] ?? '0 đ';
    final phiVanChuyen = _orderDetail?['phiVanChuyen'] ?? '0 đ';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Chi tiết
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết đơn hàng: $maDon',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Thời gian tạo: $thoiGianTao',
                      style: const TextStyle(color: AppColors.textSubtitle),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.statusOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trangThai.toString().toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.statusOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Thông tin Người gửi & Người nhận (2 cột)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInfoBox(
                    title: 'Thông tin người gửi',
                    name: nguoiGui['hoTen'] ?? 'N/A',
                    phone: nguoiGui['soDienThoai'] ?? 'N/A',
                    address: nguoiGui['diaChi'] ?? _orderDetail?['diemLayHang'] ?? 'N/A',
                    icon: Icons.unarchive,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoBox(
                    title: 'Thông tin người nhận',
                    name: nguoiNhan['hoTen'] ?? 'N/A',
                    phone: nguoiNhan['soDienThoai'] ?? 'N/A',
                    address: nguoiNhan['diaChi'] ?? _orderDetail?['diemGiaoHang'] ?? 'N/A',
                    icon: Icons.archive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chi tiết gói hàng & Tiền thu hộ COD
            Card(
              elevation: 0,
              color: AppColors.backgroundGray,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric('Khối lượng', '$khoiLuong'),
                    _buildMetric('Kích thước', '$kichThuoc'),
                    _buildMetric('Tiền COD', '$tienCod', isBold: true, color: AppColors.primaryRed),
                    _buildMetric('Phí vận chuyển', '$phiVanChuyen'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String name,
    required String phone,
    required String address,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryRed),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Họ tên: $name', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('SĐT: $phone'),
          const SizedBox(height: 4),
          Text('Địa chỉ: $address'),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, {bool isBold = false, Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSubtitle, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.textMain,
          ),
        ),
      ],
    );
  }
}