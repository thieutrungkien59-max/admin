import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        children: [
          // ===================================================================
          // CỘT TRÁI: HÌNH ẢNH MINH HỌA (Chiếm 60% màn hình)
          // ===================================================================
          Expanded(
            flex: 6, 
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryRed, // Nếu không có hình thì dùng nền đỏ
                image: DecorationImage(
                  image: AssetImage('assets/images/login_illustration.jpg'), // Đường dẫn hình của ông
                  fit: BoxFit.cover,
                ),
              ),
              // Lớp phủ màu mờ (Overlay) để chữ nổi bật hơn
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(60.0),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LogiRoute', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 16),
                    Text('Tối ưu hóa hành trình vận tải nội đô', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('Nền tảng điều phối thông minh dành riêng cho hạ tầng logistics tại Thành phố Hồ Chí Minh.', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          
          // ===================================================================
          // CỘT PHẢI: FORM ĐĂNG NHẬP (Chiếm 40% màn hình)
          // ===================================================================
          Expanded(
            flex: 4, 
            child: Center( // Căn giữa toàn bộ form để không bị giãn
              child: SingleChildScrollView(
                child: Container(
                  width: 400, // CHỐT CHẶN: Form chỉ rộng đúng 400px (Rất quan trọng)
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề form
                      const Text('Đăng nhập LogiRoute', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                      const SizedBox(height: 8),
                      const Text('Hệ thống điều phối vận tải TP.HCM', style: TextStyle(color: AppColors.textSubtitle, fontSize: 16)),
                      const SizedBox(height: 40),
                      
                      // Input: Tài khoản
                      const Text('Tài khoản (Email/Username)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'admin@logiroute.vn',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: AppColors.backgroundGray,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryRed)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Input: Mật khẩu
                      const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundGray,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryRed)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Ghi nhớ & Quên mật khẩu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primaryRed,
                                onChanged: (val) => setState(() => _rememberMe = val!),
                              ),
                              const Text('Ghi nhớ phiên', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Quên mật khẩu?', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Nút Đăng nhập
                      SizedBox(
                        width: double.infinity, 
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                          ),
                          onPressed: () => context.go('/dashboard'),
                          child: const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Footer phiên bản
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.statusGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.statusGreen, size: 20),
                            SizedBox(width: 8),
                            Expanded(child: Text('NETWORK READY - REAL-TIME SYNC', style: TextStyle(color: AppColors.statusGreen, fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text('Cổng quản trị nội bộ. Vui lòng không chia sẻ tài khoản.\nV2.4.0-STABLE / © 2026 LogiRoute Admin', 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSubtitle, fontSize: 12)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}