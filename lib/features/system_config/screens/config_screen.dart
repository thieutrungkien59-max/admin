import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/warning_note_card.dart';
import '../widgets/day_selector_widget.dart';

class SystemConfigScreen extends StatelessWidget {
  const SystemConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cấu hình tham số hệ thống',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Quản lý các quy định vận hành, giờ cao điểm và chính sách thù lao.',
                        style: TextStyle(color: AppColors.textSubtitle)),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Hủy thay đổi')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu cấu hình'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CỘT TRÁI: ĐIỀU CHỈNH GIỜ CAO ĐIỂM
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Quy định 10 (QD10) - Khung giờ cao điểm',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.statusGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('ĐANG KÍCH HOẠT',
                                    style: TextStyle(
                                        color: AppColors.statusGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: '07:30 AM',
                                  decoration: const InputDecoration(
                                    labelText: 'Giờ bắt đầu',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: '09:00 AM',
                                  decoration: const InputDecoration(
                                    labelText: 'Giờ kết thúc',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: '1.5x',
                                  decoration: const InputDecoration(
                                    labelText: 'Hệ số phụ phí (Surcharge)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text('Các ngày áp dụng trong tuần',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const DaySelectorWidget(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // CỘT PHẢI: CARD LƯU Ý VẬN HÀNH
                  const Expanded(
                    flex: 1,
                    child: WarningNoteCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}