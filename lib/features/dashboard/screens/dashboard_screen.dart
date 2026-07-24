import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tổng quan vận hành hôm nay', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildStatCard('Tổng đơn hàng', '1,245', Icons.inventory_2, Colors.blue),
            const SizedBox(width: 20),
            _buildStatCard('Đang giao', '432', Icons.local_shipping, AppColors.statusOrange),
            const SizedBox(width: 20),
            _buildStatCard('Tài xế Online', '128', Icons.motorcycle, AppColors.statusGreen),
            const SizedBox(width: 20),
            _buildStatCard('Cảnh báo COD', '3', Icons.warning_amber_rounded, AppColors.statusRed),
          ],
        ),
        const SizedBox(height: 30),
        // Chỗ này sau ông gắn biểu đồ (Chart) vào
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: const Center(child: Text('Khu vực hiển thị Biểu đồ Doanh thu (Dùng thư viện fl_chart)', style: TextStyle(color: Colors.grey))),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 28)),
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