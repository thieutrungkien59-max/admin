import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
// TODO: Thay đổi đường dẫn import này cho đúng với cấu trúc thư mục của bạn
import 'package:admin/services/api_service.dart';

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
  void initState() {
    super.initState();
    _loadSavedLoginInfo();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }  
  
  /// Tải thông tin ghi nhớ từ bộ nhớ thiết bị
  Future<void> _loadSavedLoginInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isRemembered = prefs.getBool('remember_me') ?? false;

      if (isRemembered) {
        final savedUsername = prefs.getString('saved_username') ?? '';
        setState(() {
          _rememberMe = true;
          _usernameController.text = savedUsername;
        });
      }
    } catch (e) {
      debugPrint('Lỗi không tìm thấy tài khoản đã lưu: $e');
    }
  }

  /// Lưu hoặc xóa thông tin tài khoản dựa theo trạng thái Checkbox
  Future<void> _saveOrClearSession(String username) async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_username', username);
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_username');
    }
  }

  // ===================================================================
  // LOGIC ĐĂNG NHẬP
  // ===================================================================
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final isSuccess = await _checkLoginWithApi(username, password);

      if (mounted) {
        if (isSuccess) {
          await _saveOrClearSession(username);

          if (mounted) {
            context.go('/dashboard');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

 // ===================================================================
  // HÀM GỌI API KIỂM TRA TÀI KHOẢN
  // ===================================================================
  Future<bool> _checkLoginWithApi(String username, String password) async {
    try {
      // 1. Đăng nhập lấy Token (Token đã tự động lưu ngầm ở bước này)
      await ApiService.login(username, password);

      // 2. Lấy thông tin user hiện tại
      final userData = await ApiService.getMe();

      // 3. Chặn đăng nhập nếu không phải Admin
      if (userData['role'] != 'ADMIN') {
        // BỔ SUNG QUAN TRỌNG: Xóa ngay Token rác ra khỏi bộ nhớ
        await ApiService.logout();
        
        throw Exception('Truy cập bị từ chối. Chỉ tài khoản ADMIN mới được phép đăng nhập!');
      }

      // 4. Lưu thông tin phiên đăng nhập để các màn Admin sử dụng
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_ma_tk', userData['userId'].toString());
      await prefs.setString('admin_ten_dang_nhap', userData['email'].toString());
      await prefs.setString('admin_role', userData['role'].toString());

      return true;
    } catch (e) {
      rethrow;
    }
  }
  // ===================================================================
  // PHẦN GIAO DIỆN (UI) - Giữ nguyên không đổi
  // ===================================================================
  @override
  Widget build(BuildContext context) {
    final primaryRedColor = AppColors.primaryRed;

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
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryRedColor,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/login_illustration.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: const Color(0xFFC62828).withValues(alpha: 0.85),
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

            const Text(
              'Tài khoản (Email)',
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Mật khẩu (Password)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
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