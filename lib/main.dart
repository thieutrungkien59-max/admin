import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Import cấu hình màu sắc
import 'core/constants/app_colors.dart';
// Import các màn hình Giao diện (Screens)
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/admin_main_layout.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dispatch_map/screens/dispatch_map_screen.dart';
import 'features/dispatch_center/screens/dispatch_center_screen.dart';
import 'features/order_management/screens/order_list_screen.dart';
import 'features/order_management/screens/order_detail_screen.dart';
import 'features/cod_reconciliation/screens/cod_review_screen.dart';
import 'features/shipper_management/screens/shipper_list_screen.dart';
import 'features/shipper_management/screens/approve_shipper_screen.dart';
import 'features/system_config/screens/config_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LogiRouteAdminApp());
}

// =========================================================================
// CẤU HÌNH ĐỊNH TUYẾN CHUYỂN TRANG (GO ROUTER TỔNG)
// =========================================================================
final GoRouter _router = GoRouter(
  initialLocation: '/login', // Khi mở Web lên sẽ nhảy vào trang Đăng nhập trước
  routes: [
    // 1. Luồng độc lập: Trang Đăng Nhập (Không hiển thị Sidebar Menu & Topbar)
    GoRoute(
      path: '/login',
      builder: (context, state) => const AdminLoginScreen(),
    ),

    // 2. Luồng Quản trị (Dùng ShellRoute để giữ cố định Sidebar Menu & Topbar)
    ShellRoute(
      builder: (context, state, child) {
        return AdminMainLayout(child: child); // Gọi bộ khung Layout chung
      },
      routes: [
        // Trang Bảng điều khiển (Dashboard Tổng quan)
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),

        // Trang Bản đồ trực tuyến(UC05)
        GoRoute(
          path: '/dispatch_map',
          builder: (context, state) => const DispatchMapScreen(),
        ),

        // Trang Trung tâm điều phối (UC04)
        GoRoute(
          path: '/dispatch_center',
          builder: (context, state) => const DispatchCenterScreen(),
        ),

        // Trang Quản lý Danh sách Đơn hàng
        GoRoute(
          path: '/order_management',
          builder: (context, state) => const OrderListScreen(),
        ),

        // Trang Chi tiết Đơn hàng
        GoRoute(
          path: '/order_detail',
          builder: (context, state) => const OrderDetailScreen(),
        ),

        // Trang Đối soát tài chính COD (UC12)
        GoRoute(
          path: '/cod_reconciliation',
          builder: (context, state) => const CodReviewScreen(),
        ),

        // Trang Danh sách & Quản lý Tài xế
        GoRoute(
          path: '/shipper_management',
          builder: (context, state) => const ShipperListScreen(),
        ),

        // Trang Duyệt hồ sơ Tài xế mới (UC16)
        GoRoute(
          path: '/approve_shipper',
          builder: (context, state) => const ApproveShipperScreen(),
        ),

        // Trang Cấu hình tham số & Giờ cao điểm (UC06)
        GoRoute(
          path: '/system_config',
          builder: (context, state) => const SystemConfigScreen(),
        ),
      ],
    ),
  ],

  // Bắt lỗi khi gõ sai đường dẫn URL trên trình duyệt Web (404 Page)
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '404 - Không tìm thấy trang: ${state.uri}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Quay lại Trang chủ'),
          ),
        ],
      ),
    ),
  ),
);

// =========================================================================
// WIDGET GỐC CỦA ỨNG DỤNG LOGIROUTE ADMIN
// =========================================================================
class LogiRouteAdminApp extends StatelessWidget {
  const LogiRouteAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LogiRoute Admin - Hệ Thống Điều Phối Vận Tải TP.HCM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.backgroundGray,
        primaryColor: AppColors.primaryRed,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      routerConfig: _router, // Gắn bộ router ở trên vào ứng dụng
    );
  }
}