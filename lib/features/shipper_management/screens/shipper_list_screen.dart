import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class ShipperListScreen extends StatelessWidget {
  const ShipperListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Lái xe / Shipper',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => context.go('/approve-shipper'),
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('Duyệt hồ sơ mới (UC16)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.backgroundGray),
                columns: const [
                  DataColumn(label: Text('Mã Tài Xế', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Họ & Tên', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Số Điện Thoại', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Biển Số Xe', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Trạng Thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Hành Động', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: List.generate(8, (index) {
                  bool isApproved = index != 1; // Giả lập tài xế số 1 đang chờ duyệt
                  return DataRow(cells: [
                    DataCell(Text('SP-00${index + 1}')),
                    DataCell(Text('Trần Văn ${String.fromCharCode(65 + index)}')),
                    DataCell(Text('0901 234 00$index')),
                    DataCell(Text('59-X1 888.0$index')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? AppColors.statusGreen.withValues(alpha: 0.1)
                              : AppColors.statusOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isApproved ? 'Hoạt động' : 'Chờ xét duyệt',
                          style: TextStyle(
                            color: isApproved ? AppColors.statusGreen : AppColors.statusOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.blue),
                            onPressed: () => context.go('/approve-shipper'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.block, color: AppColors.statusRed),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}