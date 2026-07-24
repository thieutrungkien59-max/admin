import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Xử lý gọi API Đăng nhập
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryRedColor = AppColors.primaryRed; // Màu đỏ LogiRoute

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          if (isMobile) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Center(
                child: _buildRightForm(
                  context,
                  width: double.infinity,
                  redColor: primaryRedColor,
                ),
              ),
            );
          }

          return Row(
            children: [
              // ===================================================================
              // CỘT TRÁI: BANNER ĐỎ & THÔNG TIN LOGIROUTE (50% màn hình)
              // ===================================================================
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryRedColor, 
                    image: DecorationImage(
                      image: AssetImage('assets/images/login_illustration.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    // Lớp phủ đỏ trong suốt giống hình mẫu
                    color: const Color(0xFFC62828).withValues(alpha: 0.85),
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Logo Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.local_shipping_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'LogiRoute',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Title & Subtitle ở giữa
                        const Text(
                          'Tối ưu hóa hành trình vận tải\nnội đô',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nền tảng điều phối thông minh dành riêng cho hạ tầng logistics tại Thành phố Hồ Chí Minh.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                        ),

                        const Spacer(),

                        // Bottom Status Indicators
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.emergency,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'NETWORK READY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Row(
                              children: [
                                Icon(
                                  Icons.sync,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'REAL-TIME SYNC',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===================================================================
              // CỘT PHẢI: FORM ĐĂNG NHẬP (50% màn hình)
              // ===================================================================
              Expanded(
                flex: 5,
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildRightForm(
                      context,
                      width: 420,
                      redColor: primaryRedColor,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget Form đăng nhập bên phải
  Widget _buildRightForm(
    BuildContext context, {
    required double width,
    required Color redColor,
  }) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    );

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Form
            const Text(
              'Đăng nhập LogiRoute',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hệ thống điều phối vận tải TP.HCM',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 36),

            // Field 1: Tài khoản
            const Text(
              'Tài khoản (Email/Username)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Vui lòng nhập tài khoản'
                  : null,
              decoration: InputDecoration(
                hintText: 'admin@logiroute.vn',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                suffixIcon: const Icon(
                  Icons.alternate_email,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: inputBorder.copyWith(
                  borderSide: BorderSide(color: redColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Field 2: Mật khẩu (Label + Link Quên mật khẩu nằm chung hàng)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mật khẩu (Password)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: redColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Vui lòng nhập mật khẩu'
                  : null,
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: inputBorder.copyWith(
                  borderSide: BorderSide(color: redColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Checkbox: Ghi nhớ phiên đăng nhập
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: redColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    onChanged: (val) =>
                        setState(() => _rememberMe = val ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ghi nhớ phiên đăng nhập',
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Nút Đăng nhập Red
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 36),

            // Chú thích bảo mật
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shield_outlined, size: 16, color: Color(0xFF94A3B8)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cổng quản trị nội bộ. Vui lòng không chia sẻ tài khoản.',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Footer Phiên bản
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'V2.4.0-STABLE',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                Text(
                  '© 2024 LogiRoute Admin',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
