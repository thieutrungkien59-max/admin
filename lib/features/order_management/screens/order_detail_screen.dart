import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, this.orderId = 'LR-1029'});

  @override
  Widget build(BuildContext context) {
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
                    Text('Chi tiết đơn hàng: $orderId',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Thời gian tạo: 10:30 AM - 24/07/2026',
                        style: TextStyle(color: AppColors.textSubtitle)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.statusOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('ĐANG GIAO HÀNG',
                      style: TextStyle(color: AppColors.statusOrange, fontWeight: FontWeight.bold)),
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
                    title: 'Thông tin người gửi (BM01)',
                    name: 'Nguyễn Văn A',
                    phone: '0912 345 678',
                    address: '123 Đường Lê Lợi, Phường Bến Nghé, Quận 1, TP.HCM',
                    icon: Icons.unarchive,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoBox(
                    title: 'Thông tin người nhận',
                    name: 'Trần Thị B',
                    phone: '0987 654 321',
                    address: '456 Đường CMT8, Phường 11, Quận 3, TP.HCM',
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
                    _buildMetric('Khối lượng', '2.5 kg'),
                    _buildMetric('Kích thước', '30 x 20 x 10 cm'),
                    _buildMetric('Tiền COD', '250,000 đ', isBold: true, color: AppColors.primaryRed),
                    _buildMetric('Phí vận chuyển', '32,000 đ'),
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
          Text('SĐT: $phone'),
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