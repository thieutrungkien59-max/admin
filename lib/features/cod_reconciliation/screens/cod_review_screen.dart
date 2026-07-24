import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CodReviewScreen extends StatelessWidget {
  const CodReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Đối soát nộp tiền COD cuối ca', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: 4,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                // Giả lập tài xế số 2 bị trễ hạn nộp tiền
                bool isLate = index == 1; 
                return ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  tileColor: isLate ? AppColors.statusRed.withOpacity(0.05) : Colors.white,
                  leading: CircleAvatar(backgroundColor: isLate ? AppColors.statusRed : AppColors.primaryRedLight, child: const Icon(Icons.person, color: Colors.white)),
                  title: Text('Shipper: Lê Văn ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: isLate ? AppColors.statusRed : Colors.black)),
                  subtitle: Text(isLate ? 'CẢNH BÁO: Trễ hạn nộp tiền (Quá 10:00 AM)' : 'Hạn chót: 10:00 AM ngày mai', style: TextStyle(color: isLate ? AppColors.statusRed : Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Cần thu: 1,500,000 đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: isLate ? AppColors.statusRed : AppColors.statusGreen),
                        child: const Text('Xác nhận đã nộp', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}