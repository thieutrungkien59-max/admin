import 'package:flutter/material.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/services/api_service.dart';

class ShipperListScreen extends StatefulWidget {
  const ShipperListScreen({super.key});

  @override
  State<ShipperListScreen> createState() => _ShipperListScreenState();
}

class _ShipperListScreenState extends State<ShipperListScreen> {
  final Color primaryRed = const Color(0xFFD32F2F);
  List<ShipperModel> _shippers = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchShippers();
  }

  Future<void> _fetchShippers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<dynamic> raw = await ApiService.getDanhSachShipper();
      setState(() {
        _shippers = raw.map((item) => ShipperModel.fromJson(item as Map<String, dynamic>)).toList();
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
    final filteredShippers = _shippers.where((s) {
      if (_filterStatus == 'ONLINE') return s.isOnline;
      if (_filterStatus == 'OFFLINE') return !s.isOnline;
      return true;
    }).toList();

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quản lý Đội ngũ Shipper', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Tổng số tài xế: ${_shippers.length}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterStatus,
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('Tất cả trạng thái')),
                            DropdownMenuItem(value: 'ONLINE', child: Text('Đang Online')),
                            DropdownMenuItem(value: 'OFFLINE', child: Text('Đang Offline')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _filterStatus = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Tải lại',
                      onPressed: _fetchShippers,
                    ),
                  ],
                )
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
                              const Icon(Icons.error_outline, color: Colors.red, size: 40),
                              const SizedBox(height: 8),
                              Text(_error!, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
                                onPressed: _fetchShippers,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : filteredShippers.isEmpty
                          ? const Center(child: Text('Không tìm thấy tài xế nào'))
                          : ListView.builder(
                              itemCount: filteredShippers.length,
                              itemBuilder: (context, index) {
                                final shipper = filteredShippers[index];
                                return Card(
                                  elevation: 1,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: shipper.isOnline ? Colors.green.shade100 : Colors.grey.shade300,
                                      child: Icon(Icons.person, color: shipper.isOnline ? Colors.green.shade800 : Colors.grey.shade600),
                                    ),
                                    title: Text(shipper.hoTen, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('Biển số: ${shipper.bienSo} | SĐT: ${shipper.soDienThoai}', style: const TextStyle(fontSize: 12)),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: shipper.isOnline ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: shipper.isOnline ? Colors.green.shade200 : Colors.red.shade200),
                                          ),
                                          child: Text(
                                            shipper.isOnline ? 'ONLINE' : 'OFFLINE',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: shipper.isOnline ? Colors.green.shade700 : Colors.red.shade700),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star, size: 13, color: Colors.amber.shade700),
                                            const SizedBox(width: 2),
                                            Text('${shipper.danhGia} (${shipper.soDonDaGiao} đơn)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          ],
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
}