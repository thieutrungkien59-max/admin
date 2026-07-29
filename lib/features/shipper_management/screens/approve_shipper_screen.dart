import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'package:admin/services/api_service.dart';

class ApproveShipperScreen extends StatefulWidget {
  final String shipperId;

  const ApproveShipperScreen({
    super.key,
    this.shipperId = 'HS-2026-0891',
  });

  @override
  State<ApproveShipperScreen> createState() => _ApproveShipperScreenState();
}

class _ApproveShipperScreenState extends State<ApproveShipperScreen> {
  // Checklist trạng thái
  bool _checkCccd = true;
  bool _checkGplx = true;
  bool _checkPhoto = true;
  bool _checkHistory = true;

  // Controller ghi chú và trạng thái loading
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Hàm xử lý gửi duyệt hoặc từ chối hồ sơ
  Future<void> _processApproval({required bool isApproved}) async {
    setState(() => _isSubmitting = true);

    try {
      // 🟢 Gọi API duyệt hồ sơ shipper
      await ApiService.duyetHoSoShipper({
        'shipperId': widget.shipperId,
        'isApproved': isApproved,
        'ghiChu': _noteController.text.trim(),
        'checkCccd': _checkCccd,
        'checkGplx': _checkGplx,
        'checkPhoto': _checkPhoto,
        'checkHistory': _checkHistory,
      });

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

      // Quay lại màn hình danh sách shipper
      context.go('/shippers');
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

  @override
  Widget build(BuildContext context) {
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
            // Tiêu đề
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
                      'Mã hồ sơ: ${widget.shipperId} | UC16 (Duyệt hồ sơ Shipper)',
                      style: const TextStyle(color: AppColors.textSubtitle),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isSubmitting ? null : () => context.go('/shippers'),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // Bố cục 2 Cột: Bên trái Giấy tờ - Bên phải Checklist
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CỘT BÊN TRÁI: ẢNH GIẤY TỜ
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giấy tờ tải lên',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildImageCard('Ảnh chân dung', Icons.person_pin),
                          const SizedBox(width: 16),
                          _buildImageCard('CCCD Mặt trước/sau', Icons.badge),
                          const SizedBox(width: 16),
                          _buildImageCard('GPLX & Cà vẹt xe', Icons.two_wheeler),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // CỘT BÊN PHẢI: CHECKLIST & PHÊ DUYỆT
                Expanded(
                  flex: 2,
                  child: Container(
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
                          onChanged: _isSubmitting
                              ? null
                              : (val) => setState(() => _checkCccd = val!),
                        ),
                        CheckboxListTile(
                          title: const Text('GPLX phù hợp hạng tải trọng'),
                          value: _checkGplx,
                          activeColor: AppColors.primaryRed,
                          onChanged: _isSubmitting
                              ? null
                              : (val) => setState(() => _checkGplx = val!),
                        ),
                        CheckboxListTile(
                          title: const Text('Ảnh chân dung khớp với CCCD'),
                          value: _checkPhoto,
                          activeColor: AppColors.primaryRed,
                          onChanged: _isSubmitting
                              ? null
                              : (val) => setState(() => _checkPhoto = val!),
                        ),
                        CheckboxListTile(
                          title: const Text('Tra cứu lịch sử vi phạm (An toàn)'),
                          value: _checkHistory,
                          activeColor: AppColors.primaryRed,
                          onChanged: _isSubmitting
                              ? null
                              : (val) => setState(() => _checkHistory = val!),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _noteController,
                          enabled: !_isSubmitting,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Ghi chú duyệt hồ sơ (Tùy chọn)',
                            hintText: 'Nhập lý do từ chối hoặc lưu ý cho shipper...',
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nút hành động
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.statusRed,
                                  side: const BorderSide(color: AppColors.statusRed),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _processApproval(isApproved: false),
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
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _processApproval(isApproved: true),
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
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String label, IconData icon) {
    return Expanded(
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}