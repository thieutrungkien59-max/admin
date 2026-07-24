  import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DispatchMapScreen extends StatelessWidget {
  const DispatchMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // KHU VỰC BẢN ĐỒ (BÊN TRÁI)
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Text('Khu vực nhúng Google Maps SDK\nHiển thị vị trí Real-time của Shipper', 
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black54)),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // KHU VỰC DANH SÁCH TÀI XẾ (BÊN PHẢI)
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Danh sách Shipper (Theo dõi)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.primaryRedLight, child: Icon(Icons.motorcycle, color: AppColors.primaryRed, size: 20)),
                        title: Text('Trần Văn ${String.fromCharCode(65 + index)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Trạng thái: Đang giao (2 đơn)'),
                        trailing: const Icon(Icons.circle, color: AppColors.statusGreen, size: 12),
                        onTap: () {},
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}