import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import cấu hình màu sắc
import 'core/constants/app_colors.dart';

// Import các màn hình Giao diện (Screens)
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/admin_main_layout.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dispatch_map/screens/dispatch_map_screen.dart';
import 'features/order_management/screens/order_list_screen.dart';
import 'features/order_management/screens/order_detail_screen.dart'; // Mới thêm
import 'features/cod_reconciliation/screens/cod_review_screen.dart';
import 'features/shipper_management/screens/shipper_list_screen.dart';
import 'features/shipper_management/screens/approve_shipper_screen.dart'; // Mới thêm
import 'features/system_config/screens/config_screen.dart';

void main() {
  runApp(const LogiRouteAdminApp());
}

// =========================================================================
// CẤU HÌNH ĐỊNH TUYẾN CHUYỂN TRANG (GO ROUTER TỔNG)
// =========================================================================
final GoRouter _router = GoRouter(
  initialLocation: '/login', // Khi mở Web lên sẽ nhảy vào trang Đăng nhập trước
  routes: [
    // 1. Luồng độc lập: Trang Đăng Nhập (Không hiển thị Sidebar)
    GoRoute(
      path: '/login',
      builder: (context, state) => const AdminLoginScreen(),
    ),

    // 2. Luồng Quản trị (Dùng ShellRoute để giữ cố định Sidebar Menu & Topbar)
    ShellRoute(
      builder: (context, state, child) {
        return AdminMainLayout(child: child); // Gọi bộ khung (Layout)
      },
      routes: [
        // Nhóm 6: Trang Bảng điều khiển (Dashboard Tổng quan)
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),

        // Nhóm 2: Trang Bản đồ trực tuyến & Điều phối (UC05)
        GoRoute(
          path: '/map',
          builder: (context, state) => const DispatchMapScreen(),
        ),

        // Nhóm 1: Trang Quản lý Đơn hàng
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderListScreen(),
        ),
        
        // Nhóm 1: Trang Chi tiết Đơn hàng (Popup/Sub-page)
        GoRoute(
          path: '/order-detail',
          builder: (context, state) => const OrderDetailScreen(),
        ),

        // Nhóm 4: Trang Đối soát tài chính COD (UC12)
        GoRoute(
          path: '/cod',
          builder: (context, state) => const CodReviewScreen(),
        ),

        // Nhóm 3: Trang Danh sách & Quản lý Tài xế
        GoRoute(
          path: '/shippers',
          builder: (context, state) => const ShipperListScreen(),
        ),

        // Nhóm 3: Trang Duyệt hồ sơ Tài xế mới (UC16 / Page 8 PDF)
        GoRoute(
          path: '/approve-shipper',
          builder: (context, state) => const ApproveShipperScreen(),
        ),

        // Nhóm 5: Trang Cấu hình tham số & Giờ cao điểm (UC06 / Page 9 PDF)
        GoRoute(
          path: '/config',
          builder: (context, state) => const SystemConfigScreen(),
        ),
      ],
    ),
  ],
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
        scaffoldBackgroundColor: AppColors.backgroundGray,
        primaryColor: AppColors.primaryRed,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Font chữ nhìn chuyên nghiệp giống PDF
      ),
      routerConfig: _router, // Gắn bộ router ở trên vào app
    );
  }
}