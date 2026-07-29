import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/api_service.dart'; 

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  // Biến chứa danh sách đơn hàng lấy từ API
  late Future<List<dynamic>> _futureDonHang;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Hàm để gọi lại API
  void _loadData() {
    setState(() {
      _futureDonHang = ApiService.getDonHangChoNhan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. THANH TIÊU ĐỀ VÀ NÚT LỌC / TẢI LẠI
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Đơn hàng (Realtime từ SQL)', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                ElevatedButton.icon(
                  onPressed: _loadData, // Bấm để reload lại dữ liệu mới nhất từ C#
                  icon: const Icon(Icons.refresh), 
                  label: const Text('Tải lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, 
                    foregroundColor: Colors.black, 
                    elevation: 0, 
                    side: const BorderSide(color: Colors.grey)
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. PHẦN HIỂN THỊ BẢNG DỮ LIỆU THẬT
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futureDonHang, // ✅ KẾT NỐI VỚI HÀM GỌI API THẬT
              builder: (context, snapshot) {
                // Đang tải...
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Lỗi kết nối...
                else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Lỗi kết nối Server:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                }
                // Dữ liệu trống
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Chưa có đơn hàng nào trong SQL Server!', 
                      style: TextStyle(color: Colors.grey, fontSize: 16)
                    ),
                  );
                }

                // Có dữ liệu -> Đổ vào DataTable
                final danhSachDon = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.backgroundGray),
                      columns: const [
                        DataColumn(label: Text('Mã Đơn', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Người Nhận', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Địa Chỉ Giao', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tiền COD', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Trạng Thái', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: danhSachDon.map((don) {
                        return DataRow(
                          cells: [
                            DataCell(Text(don['maDonHang']?.toString() ?? '')),
                            DataCell(Text(don['tenNguoiNhan']?.toString() ?? '')),
                            DataCell(Text(don['diaChiGiao']?.toString() ?? '')),
                            DataCell(Text('${don['tienCod'] ?? 0} đ', 
                              style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold))
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.statusOrange.withOpacity(0.1), 
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                child: Text(don['trangThai']?.toString() ?? 'CHO_XAC_NHAN', 
                                  style: const TextStyle(color: AppColors.statusOrange, fontSize: 12)
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye, color: Colors.blue), 
                                onPressed: () {
                                  // Xử lý xem chi tiết đơn hàng ở đây nếu cần
                                }
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}