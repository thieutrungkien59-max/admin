import 'package:flutter/material.dart';
import 'package:admin/models/don_hang_model.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/services/api_service.dart';

class DispatchCenterScreen extends StatefulWidget {
  const DispatchCenterScreen({super.key});

  @override
  State<DispatchCenterScreen> createState() => _DispatchCenterScreenState();
}

class _DispatchCenterScreenState extends State<DispatchCenterScreen> {
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color bgCream = const Color(0xFFF9F6F0);

  List<DonHangModel> _pendingOrders = [];
  List<ShipperModel> _recommendedShippers = [];
  DonHangModel? _selectedOrder;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDataFromApi();
  }

  Future<void> _fetchDataFromApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getDanhSachDonHang(),
        ApiService.getDanhSachShipper(),
      ]);

      final List<DonHangModel> loadedOrders = (results[0] as List)
          .map((json) => DonHangModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final List<ShipperModel> loadedShippers = (results[1] as List)
          .map((json) => ShipperModel.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        _pendingOrders = loadedOrders;
        _selectedOrder = loadedOrders.isNotEmpty ? loadedOrders.first : null;
        _recommendedShippers = loadedShippers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: bgCream,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryRed),
              const SizedBox(height: 16),
              const Text('Đang tải dữ liệu từ Server...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: bgCream,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(fontSize: 14, color: Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
                onPressed: _fetchDataFromApi,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bgCream,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 330,
            child: _buildPendingOrdersColumn(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildOrderDetailColumn(),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 340,
            child: _buildShipperRecommendationsColumn(),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrdersColumn() {
    final urgentOrders = _pendingOrders.where((o) => o.isUrgent).toList();
    final normalOrders = _pendingOrders.where((o) => !o.isUrgent).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Danh sách hàng chờ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: Text('${_pendingOrders.length} đơn', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Tải lại danh sách',
              onPressed: _fetchDataFromApi,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _pendingOrders.isEmpty
              ? const Center(child: Text('Không có đơn hàng nào chờ điều phối', style: TextStyle(color: Colors.grey, fontSize: 13)))
              : ListView(
                  children: [
                    if (urgentOrders.isNotEmpty) ...[
                      Row(
                        children: [
                          Text('* ', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Cần điều phối thủ công (>5ph)', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...urgentOrders.map((order) => _buildOrderCard(order)),
                      const SizedBox(height: 12),
                    ],
                    if (normalOrders.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('CHỜ PHÂN CÔNG TỰ ĐỘNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      ...normalOrders.map((order) => _buildOrderCard(order)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(DonHangModel order) {
    final isSelected = _selectedOrder?.id == order.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedOrder = order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryRed : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.maDon,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: order.isUrgent ? primaryRed : Colors.black87,
                  ),
                ),
                Text(
                  order.thoiGianCho,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: order.isUrgent ? primaryRed : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.scale_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${order.trongLuong} kg', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 12),
                Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(order.kichThuoc, style: const TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Text(order.diemLayHang, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: primaryRed, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Text(order.diemGiaoHang, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailColumn() {
    final order = _selectedOrder;

    if (order == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('Không có đơn hàng nào được chọn')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chi tiết đơn hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(order.maDon, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryRed)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () {}),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('THÔNG SỐ KĨ THUẬT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      _buildSpecRow('Trọng lượng:', '${order.trongLuong.toStringAsFixed(2)} kg'),
                      _buildSpecRow('Kích thước:', order.kichThuoc),
                      _buildSpecRow('Dung tích:', '${order.dungTich} m³'),
                      Row(
                        children: [
                          const SizedBox(width: 75, child: Text('Tính chất:', style: TextStyle(fontSize: 11, color: Colors.grey))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Text(
                              order.tinhChat,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('THỜI GIAN & CHI PHÍ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      _buildSpecRow('Dự kiến giao:', '${order.duKienGiaoPhut} Phút', highlightValue: true),
                      _buildSpecRow('Giá cước:', order.giaCuoc, isBold: true),
                      _buildSpecRow('Hình thức:', order.hinhThucGiao),
                      _buildSpecRow('COD:', order.tienCod, isBold: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text('TUYẾN ĐƯỜNG VẬN CHUYỂN (${order.quangDuongKm} KM)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Điểm lấy hàng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(order.diemLayHang, style: const TextStyle(fontSize: 11)),
                      Text('LH: ${order.lienHeLayHang}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, color: primaryRed, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Điểm giao hàng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(order.diemGiaoHang, style: const TextStyle(fontSize: 11)),
                      Text('LH: ${order.lienHeGiaoHang}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isBold = false, bool highlightValue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 75, child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: highlightValue ? Colors.green.shade700 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipperRecommendationsColumn() {
    final availableCount = _recommendedShippers.where((s) => s.isOnline).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Shipper đề xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    '$availableCount ONLINE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                ),
              ],
            ),
            IconButton(icon: const Icon(Icons.tune, size: 18), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _recommendedShippers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _buildShipperCard(_recommendedShippers[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildShipperCard(ShipperModel shipper) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shipper.isOnline ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: shipper.isOptimal ? primaryRed : const Color(0xFFE2E8F0),
          width: shipper.isOptimal ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shipper.isOptimal) ...[
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: primaryRed, borderRadius: BorderRadius.circular(4)),
                child: const Text('TỐI ƯU NHẤT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: shipper.isOnline ? Colors.red.shade100 : Colors.grey.shade300,
                child: Icon(Icons.person, size: 20, color: shipper.isOnline ? primaryRed : Colors.grey),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shipper.hoTen, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: shipper.isOnline ? Colors.black87 : Colors.grey)),
                    Row(
                      children: [
                        Text('BS: ${shipper.bienSo}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        if (shipper.danhGia > 0) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 12, color: Colors.amber.shade700),
                          const SizedBox(width: 2),
                          Text('${shipper.danhGia} (${shipper.soDonDaGiao} đơn)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (shipper.isOnline)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('KHOẢNG CÁCH', style: TextStyle(fontSize: 9, color: Colors.grey)),
                        Text('${shipper.khoangCachKm} km', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('RẢNH RỖI', style: TextStyle(fontSize: 9, color: Colors.grey)),
                        Text('${shipper.thoiGianRanhPhut} Phút', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryRed)),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else if (shipper.lyDoKhongKhaDung != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(shipper.lyDoKhongKhaDung!, style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: shipper.isOnline
                ? (shipper.isOptimal
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white, elevation: 0),
                        onPressed: () => _assignOrderToShipper(shipper),
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text('Chỉ định Shipper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: primaryRed, side: BorderSide(color: primaryRed)),
                        onPressed: () => _assignOrderToShipper(shipper),
                        child: const Text('Chỉ định Shipper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.grey.shade600, elevation: 0),
                    onPressed: null,
                    child: const Text('Không khả dụng', style: TextStyle(fontSize: 12)),
                  ),
          ),
        ],
      ),
    );
  }

  void _assignOrderToShipper(ShipperModel shipper) {
    if (_selectedOrder == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chỉ định đơn ${_selectedOrder!.maDon} cho tài xế ${shipper.hoTen}!'),
        backgroundColor: Colors.green.shade700,
      ),
    );

    setState(() {
      _pendingOrders.removeWhere((o) => o.id == _selectedOrder!.id);
      _selectedOrder = _pendingOrders.isNotEmpty ? _pendingOrders.first : null;
    });
  }
}