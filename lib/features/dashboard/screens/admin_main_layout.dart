// lib/features/dashboard/screens/admin_main_layout.dart

import 'package:admin/services/admin_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminMainLayout extends StatefulWidget {
  final Widget child;

  const AdminMainLayout({super.key, required this.child});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Lấy URL route hiện tại để highlight đúng item ở Sidebar
    final String currentRoute = GoRouterState.of(context).uri.toString();
    const primaryRed = Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // ==========================================
          // 1. SIDEBAR BÊN TRÁI (CỐ ĐỊNH)
          // ==========================================
          Container(
            width: 230,
            color: const Color(0xFFF9F6F0),
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: const [
                      Icon(Icons.local_shipping, color: primaryRed, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'LogiRoute',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),

                // Danh sách Menu
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildNavItem(
                        context,
                        icon: Icons.grid_view_rounded,
                        title: 'Bảng điều khiển',
                        targetRoute: '/dashboard',
                        currentRoute: currentRoute,
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.explore_outlined,
                        title: 'Bản đồ trực tuyến',
                        targetRoute: '/dispatch_map',
                        currentRoute: currentRoute,
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.local_shipping_outlined,
                        title: 'Đơn hàng',
                        targetRoute: '/order_management',
                        currentRoute: currentRoute,
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.hub_outlined,
                        title: 'Trung tâm điều phối',
                        targetRoute: '/dispatch_center',
                        currentRoute: currentRoute,
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.receipt_long_outlined,
                        title: 'Đối soát COD',
                        targetRoute: '/cod_reconciliation',
                        currentRoute: currentRoute,
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.person_outline,
                        title: 'Tài xế',
                        targetRoute: '/shipper_management',
                        currentRoute: currentRoute,
                      ),
                      _buildNavItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'Cấu hình hệ thống',
                        targetRoute: '/system_config',
                        currentRoute: currentRoute,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Profile Admin & Nút Đăng xuất
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Admin Route',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'TP.HCM Admin',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => context.go('/login'),
                        child: Row(
                          children: const [
                            Icon(Icons.logout, size: 18, color: Colors.black54),
                            SizedBox(width: 10),
                            Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. KHU VỰC PHẢI (HEADER + NỘI DUNG RUỘT)
          // ==========================================
          Expanded(
            child: Column(
              children: [
                // Header cố định phía trên
                _buildHeader(context),

                // Nội dung ruột thay đổi linh hoạt theo Route
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget tạo từng mục Menu Sidebar
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String targetRoute,
    required String currentRoute,
  }) {
    final isSelected = currentRoute.startsWith(targetRoute);
    const primaryRed = Color(0xFFD32F2F);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryRed : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black87,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        onTap: () {
          if (!isSelected) {
            context.go(targetRoute);
          }
        },
      ),
    );
  }

  Future<void> _showNotificationMenu(BuildContext context) async {
    const primaryRed = Color(0xFFD32F2F);

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<AdminNotificationItem>(
      context: context,
      position: RelativeRect.fromLTRB(overlay.size.width - 430, 58, 18, 0),
      constraints: const BoxConstraints(
        minWidth: 380,
        maxWidth: 420,
        maxHeight: 480,
      ),
      items: [
        PopupMenuItem<AdminNotificationItem>(
          enabled: false,
          child: SizedBox(
            width: 380,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Thông báo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (_notificationService.unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      _notificationService.markAllAsRead();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Đánh dấu đã đọc',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_notificationService.items.isEmpty)
          const PopupMenuItem<AdminNotificationItem>(
            enabled: false,
            child: SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Chưa có thông báo',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          ..._notificationService.items.take(10).map((notification) {
            return PopupMenuItem<AdminNotificationItem>(
              value: notification,
              padding: EdgeInsets.zero,
              child: Container(
                width: 400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                color: notification.isRead
                    ? Colors.white
                    : primaryRed.withValues(alpha: 0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: primaryRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: primaryRed,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: primaryRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.35,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _formatNotificationTime(notification.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );

    if (selected == null) {
      return;
    }

    _notificationService.markAsRead(selected.id);

    if (!context.mounted) {
      return;
    }

    if (selected.orderId != null) {
      context.go(
        '/dispatch_center?orderId=${Uri.encodeComponent(selected.orderId!)}',
      );
    } else {
      context.go('/dispatch_center');
    }
  }

  String _formatNotificationTime(DateTime value) {
    final elapsed = DateTime.now().difference(value);

    if (elapsed.inSeconds < 60) {
      return 'Vừa xong';
    }

    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} phút trước';
    }

    if (elapsed.inHours < 24) {
      return '${elapsed.inHours} giờ trước';
    }

    String two(int number) => number.toString().padLeft(2, '0');

    return '${two(value.day)}/${two(value.month)}/${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  // Header chung
  Widget _buildHeader(BuildContext context) {
    const primaryRed = Color(0xFFD32F2F);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'LogiRoute Admin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              height: 38,
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm đơn hàng, tài xế...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Thông báo',
                icon: Icon(
                  _notificationService.unreadCount > 0
                      ? Icons.notifications_outlined
                      : Icons.notifications_none_outlined,
                ),
                onPressed: () => _showNotificationMenu(context),
              ),
              if (_notificationService.unreadCount > 0)
                Positioned(
                  right: 3,
                  top: 2,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: primaryRed,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _notificationService.unreadCount > 99
                          ? '99+'
                          : '${_notificationService.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => context.go('/admin_create_order'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Tạo đơn mới',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
