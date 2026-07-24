import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class AdminMainLayout extends StatelessWidget {
  final Widget child; // Đây chính là cái ruột sẽ thay đổi
  const AdminMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Lấy đường dẫn hiện tại để bôi đỏ đúng cái Menu
    final String location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // SIDEBAR BÊN TRÁI
          Container(
            width: 250, color: AppColors.white,
            child: Column(
              children: [
                Container(
                  height: 70, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 24),
                  child: const Text('LogiRoute', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _buildMenu(context, Icons.grid_view, 'Bảng điều khiển', '/dashboard', location),
                      _buildMenu(context, Icons.settings, 'Cấu hình hệ thống', '/config', location), // Demo trang config
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // NỘI DUNG BÊN PHẢI
          Expanded(
            child: Column(
              children: [
                // HEADER TOP
                Container(
                  height: 70, color: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TP.HCM Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Tạo đơn mới'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Icons.logout, color: AppColors.primaryRed),
                            onPressed: () => context.go('/login'), // Bấm đăng xuất văng ra trang login
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                // CÁI RUỘT ĐỔI LIÊN TỤC CHÍNH LÀ ĐÂY
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm vẽ nút Menu
  Widget _buildMenu(BuildContext context, IconData icon, String title, String path, String currentLocation) {
    bool isSelected = currentLocation == path;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primaryRed : Colors.grey),
      title: Text(title, style: TextStyle(color: isSelected ? AppColors.primaryRed : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? AppColors.primaryRedLight : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () => context.go(path), // Bấm vào là đổi URL web
    );
  }
}