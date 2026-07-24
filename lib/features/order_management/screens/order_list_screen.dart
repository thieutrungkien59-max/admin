import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Đơn hàng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () {}, icon: const Icon(Icons.filter_alt_outlined), label: const Text('Lọc dữ liệu'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, side: const BorderSide(color: Colors.grey)),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(AppColors.backgroundGray),
                columns: const [
                  DataColumn(label: Text('Mã Đơn', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Người Nhận', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Địa Chỉ', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tiền COD', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Trạng Thái', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: List.generate(10, (index) => DataRow(
                  cells: [
                    // ĐỔI HẾT DATACOLUMN THÀNH DATACELL Ở ĐÂY NÈ ÔNG:
                    DataCell(Text('LR-${1029 + index}')),
                    DataCell(Text('Nguyễn Thị Khách $index')),
                    const DataCell(Text('Quận 1, TP.HCM')),
                    const DataCell(Text('250,000 đ', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.statusOrange.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: const Text('Đang giao', style: TextStyle(color: AppColors.statusOrange, fontSize: 12)),
                      )
                    ),
                    DataCell(
                      IconButton(icon: const Icon(Icons.remove_red_eye, color: Colors.blue), onPressed: () {})
                    ),
                  ]
                )),),
              ),
            ),
        ],
      ),
    );
  }
}