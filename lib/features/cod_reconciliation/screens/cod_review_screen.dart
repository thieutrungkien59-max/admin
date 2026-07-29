import 'package:flutter/material.dart';
import 'package:admin/models/cod_model.dart';
import 'package:admin/services/api_service.dart';

class CodReviewScreen extends StatefulWidget {
  const CodReviewScreen({super.key});

  @override
  State<CodReviewScreen> createState() => _CodReviewScreenState();
}

class _CodReviewScreenState extends State<CodReviewScreen> {
  final Color primaryRed = const Color(0xFFD32F2F);
  List<CodModel> _codList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCodData();
  }

  Future<void> _fetchCodData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<dynamic> data = await ApiService.getDanhSachPhieuChoDuyet();
      setState(() {
        _codList = data.map((item) => CodModel.fromJson(item as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double tongTienCod = _codList.fold(0, (sum, item) => sum + item.soTienCod);
    double tongDaDoiSoat = _codList.where((item) => item.isCompleted).fold(0, (sum, item) => sum + item.soTienCod);
    double tongChoNop = tongTienCod - tongDaDoiSoat;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Đối soát & Thống kê COD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchCodData),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Tổng Thu COD', '${tongTienCod.toStringAsFixed(0)} đ', Colors.blue),
                const SizedBox(width: 10),
                _buildStatCard('Đã Đối Soát', '${tongDaDoiSoat.toStringAsFixed(0)} đ', Colors.green),
                const SizedBox(width: 10),
                _buildStatCard('Chờ Nộp Tiền', '${tongChoNop.toStringAsFixed(0)} đ', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryRed))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 8),
                              ElevatedButton(onPressed: _fetchCodData, child: const Text('Thử lại')),
                            ],
                          ),
                        )
                      : _codList.isEmpty
                          ? const Center(child: Text('Chưa có dữ liệu đối soát'))
                          : ListView.builder(
                              itemCount: _codList.length,
                              itemBuilder: (context, index) {
                                final item = _codList[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: item.isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                                      child: Icon(
                                        Icons.payments_outlined,
                                        color: item.isCompleted ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                    title: Text('Mã đơn: ${item.maDon}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Shipper: ${item.tenShipper} | Ngày: ${item.ngayGiao}'),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${item.soTienCod.toStringAsFixed(0)} đ',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: item.isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.isCompleted ? 'Đã đối soát' : 'Chờ nộp tiền',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: item.isCompleted ? Colors.green.shade700 : Colors.orange.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}