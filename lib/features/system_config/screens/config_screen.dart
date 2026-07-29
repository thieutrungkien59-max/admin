import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/warning_note_card.dart';
import '../widgets/day_selector_widget.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/models/cau_hinh_model.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({super.key});

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _surchargeController;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool _isActive = true;
  String _maCd = 'CD01'; // Mã cấu hình từ Backend

  List<bool> _selectedDays = [true, true, true, true, true, false, false];
  Map<String, dynamic>? _initialData;

  @override
  void initState() {
    super.initState();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _surchargeController = TextEditingController();

    _fetchGioCaoDiemData();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _surchargeController.dispose();
    super.dispose();
  }

  // Convert thời gian sang định dạng 24h chuẩn TimeOnly (HH:mm:ss)
  String _formatTimeTo24Hour(String timeStr) {
    try {
      final cleanStr = timeStr.trim();
      bool isPM = cleanStr.toUpperCase().contains('PM');
      bool isAM = cleanStr.toUpperCase().contains('AM');

      String timeOnly = cleanStr.replaceAll(
        RegExp(r'\s*(AM|PM)', caseSensitive: false),
        '',
      );
      List<String> parts = timeOnly.split(':');

      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      String hStr = hour.toString().padLeft(2, '0');
      String mStr = minute.toString().padLeft(2, '0');

      return "$hStr:$mStr:00";
    } catch (e) {
      return timeStr;
    }
  }

  // 1. Lấy dữ liệu từ API
  Future<void> _fetchGioCaoDiemData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final responseData = await ApiService.getGioCaoDiem();

      if (!mounted) return;

      if (responseData is Map<String, dynamic>) {
        _initialData = responseData;
        _populateFields(responseData);
      } else if (responseData is List && responseData.isNotEmpty) {
        _initialData = responseData.first as Map<String, dynamic>;
        _populateFields(_initialData!);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    final model = CauHinhGioCaoDiemModel.fromJson(data);
    _maCd = model.maCd;
    _startTimeController.text = model.gioBatDau;
    _endTimeController.text = model.gioKetThuc;
    _surchargeController.text = model.heSoPhi.toString();

    final rawDays = data['cacNgayApDung'] ?? data['days'];
    if (rawDays != null && rawDays is List && rawDays.length == 7) {
      _selectedDays = List<bool>.from(rawDays.map((e) => e == true));
    }
  }

  // 2. Cập nhật dữ liệu - Chuẩn theo Schema Swagger
  Future<void> _saveGioCaoDiemData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Đóng gói JSON payload khớp hoàn toàn với Swagger Schema
      final Map<String, dynamic> payload = {
        'maCd': _maCd,
        'gioBatDau': _formatTimeTo24Hour(_startTimeController.text),
        'gioKetThuc': _formatTimeTo24Hour(_endTimeController.text),
        'heSoPhi':
            double.tryParse(_surchargeController.text.replaceAll('x', '')) ??
            1.5,
        'moTa': 'Khung giờ cao điểm áp dụng phụ phí',
      };

      final bool isSuccess = await ApiService.updateGioCaoDiem(payload);

      if (!mounted) return;

      if (isSuccess) {
        _initialData = Map<String, dynamic>.from(payload);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật giờ cao điểm thành công!'),
            backgroundColor: AppColors.statusGreen,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Cập nhật không thành công từ phía Server');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.statusRed,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetChanges() {
    if (_initialData != null) {
      setState(() {
        _populateFields(_initialData!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã khôi phục cài đặt ban đầu.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 30),
    );
    if (picked != null && mounted) {
      controller.text = picked.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cấu hình tham số hệ thống',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quản lý các quy định vận hành, giờ cao điểm và chính sách thù lao.',
                        style: TextStyle(color: AppColors.textSubtitle),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: (_isLoading || _isSaving)
                            ? null
                            : _resetChanges,
                        child: const Text('Hủy thay đổi'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: (_isLoading || _isSaving)
                            ? null
                            : _saveGioCaoDiemData,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save, size: 18),
                        label: Text(_isSaving ? 'Đang lưu...' : 'Lưu cấu hình'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // BODY
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.statusRed,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Lỗi tải dữ liệu: $_errorMessage',
                              style: const TextStyle(
                                color: AppColors.statusRed,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _fetchGioCaoDiemData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CỘT TRÁI
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Quy định 10 (QD10) - Khung giờ cao điểm',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _isActive
                                                  ? AppColors.statusGreen
                                                        .withValues(alpha: 0.1)
                                                  : Colors.grey.withValues(
                                                      alpha: 0.2,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _isActive
                                                  ? 'ĐANG KÍCH HOẠT'
                                                  : 'ĐÃ TẮT',
                                              style: TextStyle(
                                                color: _isActive
                                                    ? AppColors.statusGreen
                                                    : Colors.grey[700],
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Switch(
                                        value: _isActive,
                                        activeColor: AppColors.primaryRed,
                                        onChanged: (val) {
                                          setState(() => _isActive = val);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _startTimeController,
                                          readOnly: true,
                                          onTap: () =>
                                              _selectTime(_startTimeController),
                                          decoration: const InputDecoration(
                                            labelText: 'Giờ bắt đầu',
                                            suffixIcon: Icon(
                                              Icons.access_time,
                                              size: 20,
                                            ),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (val) =>
                                              val == null || val.isEmpty
                                              ? 'Chưa chọn giờ'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _endTimeController,
                                          readOnly: true,
                                          onTap: () =>
                                              _selectTime(_endTimeController),
                                          decoration: const InputDecoration(
                                            labelText: 'Giờ kết thúc',
                                            suffixIcon: Icon(
                                              Icons.access_time,
                                              size: 20,
                                            ),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (val) =>
                                              val == null || val.isEmpty
                                              ? 'Chưa chọn giờ'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _surchargeController,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Hệ số phụ phí (Surcharge)',
                                            hintText: 'VD: 1.5',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (val) =>
                                              val == null || val.isEmpty
                                              ? 'Không được trống'
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  const Text(
                                    'Các ngày áp dụng trong tuần',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  DaySelectorWidget(
                                    selectedDays: _selectedDays,
                                    onChanged: (newDays) {
                                      setState(() {
                                        _selectedDays = newDays;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // CỘT PHẢI
                          const Expanded(flex: 1, child: WarningNoteCard()),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
