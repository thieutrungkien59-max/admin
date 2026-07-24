import 'package:flutter/material.dart';

// ===================================================================
// 1. DATA MODELS (Định nghĩa cấu trúc dữ liệu chuẩn để nối API sau này)
// ===================================================================

enum DriverStatus {
  delivering,    // Đang giao
  ready,         // Sẵn sàng
  offline,       // Ngoại tuyến
  lostConnection // Mất kết nối
}

extension DriverStatusExtension on DriverStatus {
  String get label {
    switch (this) {
      case DriverStatus.delivering:
        return 'ĐANG GIAO';
      case DriverStatus.ready:
        return 'SẴN SÀNG';
      case DriverStatus.offline:
        return 'NGOẠI TUYẾN';
      case DriverStatus.lostConnection:
        return 'MẤT KẾT NỐI';
    }
  }

  Color get color {
    switch (this) {
      case DriverStatus.delivering:
        return const Color(0xFFD32F2F); // Đỏ
      case DriverStatus.ready:
        return Colors.green;           // Xanh lá
      case DriverStatus.offline:
        return Colors.grey;            // Xám
      case DriverStatus.lostConnection:
        return Colors.orange;          // Cam
    }
  }
}

class DriverOrder {
  final String id;
  final String code;
  final String status;

  DriverOrder({
    required this.id,
    required this.code,
    required this.status,
  });
}

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String plateNumber;
  final DriverStatus status;
  final double topPosition;  // Giả lập vị trí Y trên bản đồ mockup
  final double leftPosition; // Giả lập vị trí X trên bản đồ mockup
  final double latitude;     // Tọa độ thực (dùng khi gắn Google Maps / Mapbox)
  final double longitude;    // Tọa độ thực
  final DateTime lastUpdated;
  final List<DriverOrder> orders;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.plateNumber,
    required this.status,
    required this.topPosition,
    required this.leftPosition,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.lastUpdated,
    required this.orders,
  });
}

// ===================================================================
// 2. MAIN SCREEN WIDGET
// ===================================================================

class DispatchMapScreen extends StatefulWidget {
  const DispatchMapScreen({super.key});

  @override
  State<DispatchMapScreen> createState() => _DispatchMapScreenState();
}

class _DispatchMapScreenState extends State<DispatchMapScreen> {
  // Config
  final Color primaryRed = const Color(0xFFD32F2F);

  // State
  String _selectedFilterTag = 'TẤT CẢ';
  String _searchQuery = '';
  DriverModel? _selectedDriver;

  // Mock Database (Dữ liệu giả lập - Sau này thay bằng dữ liệu từ API/WebSocket)
  late List<DriverModel> _drivers;

  @override
  void initState() {
    super.initState();    
    _loadMockData();
  }

  // Khởi tạo dữ liệu giả lập
  void _loadMockData() {
    _drivers = [
      DriverModel(
        id: 'DRV-01',
        name: 'Trần Văn B',
        phone: '0901234567',
        plateNumber: '59-X1 12345',
        status: DriverStatus.delivering,
        topPosition: 180,
        leftPosition: 280,
        lastUpdated: DateTime.now().subtract(const Duration(seconds: 12)),
        orders: [
          DriverOrder(id: '1', code: 'LR-1029', status: 'ĐANG GIAO'),
          DriverOrder(id: '2', code: 'LR-1030', status: 'ĐANG GIAO'),
        ],
      ),
      DriverModel(
        id: 'DRV-02',
        name: 'Nguyễn Văn A',
        phone: '0988888888',
        plateNumber: '59-K2 99999',
        status: DriverStatus.lostConnection,
        topPosition: 320,
        leftPosition: 200,
        lastUpdated: DateTime.now().subtract(const Duration(seconds: 45)),
        orders: [
          DriverOrder(id: '3', code: 'LR-1011', status: 'ĐANG GIAO'),
        ],
      ),
      DriverModel(
        id: 'DRV-03',
        name: 'Lê Hoàng C',
        phone: '0912345678',
        plateNumber: '59-P1 54321',
        status: DriverStatus.ready,
        topPosition: 420,
        leftPosition: 380,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
        orders: [],
      ),
      DriverModel(
        id: 'DRV-04',
        name: 'Phạm Minh D',
        phone: '0933445566',
        plateNumber: '59-Z1 88888',
        status: DriverStatus.offline,
        topPosition: 250,
        leftPosition: 450,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        orders: [],
      ),
    ];

    // Mặc định chọn tài xế đầu tiên để hiển thị chi tiết
    if (_drivers.isNotEmpty) {
      _selectedDriver = _drivers.first;
    }
  }

  // --- GETTERS DỮ LIỆU ĐỘNG ---
  
  // 1. Danh sách tài xế đã qua bộ lọc (Search + Filter Tag)
  List<DriverModel> get _filteredDrivers {
    return _drivers.where((driver) {
      // Lọc theo Search Query (Tên hoặc SĐT)
      final matchesSearch = driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.phone.contains(_searchQuery);

      if (!matchesSearch) return false;

      // Lọc theo Status Tag
      if (_selectedFilterTag == 'TẤT CẢ') return true;
      if (_selectedFilterTag == 'ĐANG GIAO') return driver.status == DriverStatus.delivering;
      if (_selectedFilterTag == 'SẴN SÀNG') return driver.status == DriverStatus.ready;
      if (_selectedFilterTag == 'NGOẠI TUYẾN') return driver.status == DriverStatus.offline;

      return true;
    }).toList();
  }

  // 2. Đếm số lượng tài xế theo trạng thái để hiển thị Legend
  int _countStatus(DriverStatus status) {
    return _drivers.where((d) => d.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Row(
        children: [
          // 1. Bản đồ trung tâm
          Expanded(child: _buildMapSection()),

          // 2. Panel chi tiết tài xế bên phải
          _buildDriverDetailPanel(),
        ],
      ),
    );
  }

  // ===================================================================
  // BẢN ĐỒ TRUNG TÂM & MARKERS ĐỘNG
  // ===================================================================
  Widget _buildMapSection() {
    final filteredList = _filteredDrivers;

    return Container(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          // Background Bản đồ mockup
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_illustration.png',
              fit: BoxFit.cover,
            ),
          ),

          // Lớp phủ tối nhẹ
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),

          // --- Search bar & Filter Chips đè trên bản đồ ---
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ô Tìm kiếm
                  SizedBox(
                    width: 320,
                    height: 36,
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm Shipper theo tên, SĐT...',
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : const Icon(Icons.tune, size: 18),
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Filter Chips
                  Row(
                    children: [
                      _buildFilterChip('TẤT CẢ'),
                      _buildFilterChip('ĐANG GIAO'),
                      _buildFilterChip('SẴN SÀNG'),
                      _buildFilterChip('NGOẠI TUYẾN'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- RENDER DANH SÁCH MARKER DỮ LIỆU ĐỘNG ---
          ...filteredList.map((driver) {
            final isSelected = _selectedDriver?.id == driver.id;

            return Positioned(
              top: driver.topPosition,
              left: driver.leftPosition,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDriver = driver;
                  });
                },
                child: _buildMapMarker(
                  driver: driver,
                  isSelected: isSelected,
                ),
              ),
            );
          }),

          // --- Legend đếm số lượng tài xế động ở góc dưới ---
          Positioned(
            bottom: 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildLegendItem(
                    DriverStatus.delivering.color,
                    'Đang giao (${_countStatus(DriverStatus.delivering)})',
                  ),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                    DriverStatus.ready.color,
                    'Sẵn sàng (${_countStatus(DriverStatus.ready)})',
                  ),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                    DriverStatus.offline.color,
                    'Ngoại tuyến (${_countStatus(DriverStatus.offline)})',
                  ),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                    DriverStatus.lostConnection.color,
                    'Mất kết nối (${_countStatus(DriverStatus.lostConnection)})',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Marker Widget động
  Widget _buildMapMarker({
    required DriverModel driver,
    bool isSelected = false,
  }) {
    final color = driver.status.color;
    final showName = isSelected || driver.status == DriverStatus.lostConnection;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showName)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Text(
              driver.status == DriverStatus.lostConnection
                  ? '${driver.name} - Mất kết nối'
                  : driver.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Icon(
          Icons.location_on,
          color: color,
          size: isSelected ? 38 : 28,
        ),
      ],
    );
  }

  // Filter Chip Widget
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilterTag == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterTag = label),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryRed : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Legend Item Widget
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ===================================================================
  // PANEL CHI TIẾT TÀI XẾ ĐỘNG (BÊN PHẢI)
  // ===================================================================
  Widget _buildDriverDetailPanel() {
    final driver = _selectedDriver;

    return Container(
      width: 310,
      margin: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: driver == null
          ? const Center(
              child: Text(
                'Vui lòng chọn một tài xế trên bản đồ',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Panel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chi tiết Tài xế',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _selectedDriver = null;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Thông tin tài xế
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: driver.status.color,
                      child: const Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SĐT: ${driver.phone}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Biển số xe & Trạng thái
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BIỂN SỐ XE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            driver.plateNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: driver.status.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          driver.status.label,
                          style: TextStyle(
                            color: driver.status.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Danh sách đơn hàng đang giữ
                Text(
                  'ĐƠN HÀNG ĐANG GIỮ (${driver.orders.length})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),

                if (driver.orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Hiện không giữ đơn hàng nào',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: driver.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final order = driver.orders[index];
                        return _buildOrderItem(order.code, order.status);
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Thời gian cập nhật vị trí
                Row(
                  children: [
                    const Icon(Icons.history, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text(
                      'Cập nhật: ',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _formatLastUpdated(driver.lastUpdated),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2 Nút thao tác phía dưới
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã gửi thông báo tới ${driver.name}')),
                      );
                    },
                    child: const Text(
                      'Gửi thông báo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryRed,
                      side: BorderSide(color: primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Demo đổi trạng thái tài xế sang Offline ngay lập tức
                      setState(() {
                        _drivers = _drivers.map((d) {
                          if (d.id == driver.id) {
                            return DriverModel(
                              id: d.id,
                              name: d.name,
                              phone: d.phone,
                              plateNumber: d.plateNumber,
                              status: DriverStatus.offline,
                              topPosition: d.topPosition,
                              leftPosition: d.leftPosition,
                              lastUpdated: DateTime.now(),
                              orders: d.orders,
                            );
                          }
                          return d;
                        }).toList();
                        _selectedDriver = _drivers.firstWhere((d) => d.id == driver.id);
                      });
                    },
                    child: const Text(
                      'Ép ngoại tuyến',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper hiển thị thời gian cập nhật đơn giản
  String _formatLastUpdated(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds} giây trước';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    return '${diff.inHours} giờ trước';
  }

  // Item đơn hàng trong Panel
  Widget _buildOrderItem(String code, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            code,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: primaryRed,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: primaryRed,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}