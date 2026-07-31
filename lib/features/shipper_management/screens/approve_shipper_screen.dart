import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'package:admin/services/api_service.dart';

class ApproveShipperScreen extends StatefulWidget {
  final String shipperId;

  const ApproveShipperScreen({
    super.key,
    required this.shipperId,
  });

  @override
  State<ApproveShipperScreen> createState() => _ApproveShipperScreenState();
}

class _ApproveShipperScreenState extends State<ApproveShipperScreen> {
  // Checklist kiểm tra
  bool _checkCccd = false;
  bool _checkGplx = false;
  bool _checkPhoto = false;
  bool _checkHistory = false;

  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoadingDetail = true;

  // Dữ liệu hồ sơ giả lập/nhận từ API
  Map<String, dynamic>? _shipperData;

  @override
  void initState() {
    super.initState();
    _loadShipperDetail();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Tải thông tin chi tiết và ảnh giấy tờ của Shipper
  Future<void> _loadShipperDetail() async {
    try {
      // Gọi API lấy thông tin chi tiết hồ sơ shipper
      final data = await ApiService.getChiTietShipper(widget.shipperId);
      if (!mounted) return;
      setState(() {
        _shipperData = data;
        _isLoadingDetail = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingDetail = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải chi tiết hồ sơ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm xử lý gửi duyệt hoặc từ chối hồ sơ
  Future<void> _processApproval({required bool isApproved}) async {
    final noteText = _noteController.text.trim();

    // 1. Kiểm tra ràng buộc khi TỪ CHỐI (Bắt buộc nhập lý do)
    if (!isApproved && noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập lý do từ chối vào ô ghi chú!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Cảnh báo khi PHÊ DUYỆT nhưng chưa tích đủ checklist
    if (isApproved && !(_checkCccd && _checkGplx && _checkPhoto && _checkHistory)) {
      final confirm = await _showConfirmDialog(
        title: 'Cảnh báo checklist',
        content: 'Bạn chưa tích chọn đủ các mục kiểm tra. Bạn có chắc chắn vẫn muốn phê duyệt hồ sơ này?',
      );
      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiService.duyetHoSoShipper(
        maShipper: widget.shipperId,
        isApproved: isApproved,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproved
                ? 'Đã phê duyệt hồ sơ shipper thành công!'
                : 'Đã từ chối hồ sơ shipper!',
          ),
          backgroundColor: isApproved ? AppColors.statusGreen : AppColors.statusRed,
        ),
      );

      context.go('/shipper_list_screen'); // Quay lại danh sách shipper sau khi phê duyệt/từ chối
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Dialog xác nhận hành động
  Future<bool?> _showConfirmDialog({required String title, required String content}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tiếp tục', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Xem phóng to ảnh giấy tờ
  void _previewImage(String title, String? imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                    )
                  : Container(
                      height: 250,
                      child: Center(child: Text('Không có hình ảnh hiển thị')),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDetail) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chi tiết phê duyệt hồ sơ đăng ký mới',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Mã hồ sơ: ${widget.shipperId} | Tên: ${_shipperData?['hoTen'] ?? 'N/A'}',
                      style: const TextStyle(color: AppColors.textSubtitle),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isSubmitting ? null : () => context.go('/shipper_list_screen'),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // Responsive Layout: Tự động chuyển 1 cột trên màn hình hẹp
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                
                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildDocumentSection()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildChecklistSection()),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildDocumentSection(),
                    const SizedBox(height: 24),
                    _buildChecklistSection(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Cột trái: Hiển thị các ô giấy tờ
  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giấy tờ tải lên (Nhấn để phóng to)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildImageCard(
              'Ảnh chân dung',
              Icons.person_pin,
              _shipperData?['anhChanDungUrl'],
            ),
            _buildImageCard(
              'CCCD Mặt trước/sau',
              Icons.badge,
              _shipperData?['anhCccdUrl'],
            ),
            _buildImageCard(
              'GPLX & Cà vẹt xe',
              Icons.two_wheeler,
              _shipperData?['anhGplxUrl'],
            ),
          ],
        ),
      ],
    );
  }

  // Cột phải: Form kiểm tra & Nút Phê duyệt/Từ chối
  Widget _buildChecklistSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh mục kiểm tra',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('CCCD còn thời hạn hiệu lực'),
            value: _checkCccd,
            activeColor: AppColors.primaryRed,
            onChanged: _isSubmitting ? null : (val) => setState(() => _checkCccd = val!),
          ),
          CheckboxListTile(
            title: const Text('GPLX phù hợp hạng tải trọng'),
            value: _checkGplx,
            activeColor: AppColors.primaryRed,
            onChanged: _isSubmitting ? null : (val) => setState(() => _checkGplx = val!),
          ),
          CheckboxListTile(
            title: const Text('Ảnh chân dung khớp với CCCD'),
            value: _checkPhoto,
            activeColor: AppColors.primaryRed,
            onChanged: _isSubmitting ? null : (val) => setState(() => _checkPhoto = val!),
          ),
          CheckboxListTile(
            title: const Text('Tra cứu lịch sử vi phạm (An toàn)'),
            value: _checkHistory,
            activeColor: AppColors.primaryRed,
            onChanged: _isSubmitting ? null : (val) => setState(() => _checkHistory = val!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            enabled: !_isSubmitting,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Ghi chú / Lý do từ chối',
              hintText: 'Bắt buộc nhập khi chọn từ chối hồ sơ...',
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusRed,
                    side: const BorderSide(color: AppColors.statusRed),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSubmitting ? null : () => _processApproval(isApproved: false),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Từ chối hồ sơ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSubmitting ? null : () => _processApproval(isApproved: true),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Phê duyệt hồ sơ'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildImageCard(String label, IconData icon, String? imageUrl) {
    return InkWell(
      onTap: () => _previewImage(label, imageUrl),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Icon(icon, size: 48, color: Colors.grey[600]),
                  ),
                ),
              )
            else
              Icon(icon, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}