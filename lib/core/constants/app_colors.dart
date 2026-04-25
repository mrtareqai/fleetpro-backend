import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 1. Brand Colors
  static const Color primary = Color(0xFF4318FF);
  static const Color primaryDark = Color(0xFF2B0A9B);
  static const Color primaryLight = Color(0xFFE9E3FF);
  static const Color primaryDarkTheme = Color(0xFF7551FF);
  static const Color accent = Color(0xFF00B5D8);

  // 2. Sidebar
  // Light
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color sidebarHover = Color(0xFFF4F7FE);
  static const Color sidebarActive = primary;
  static const Color sidebarText = Color(0xFFA3AED0);
  
  // Dark
  static const Color sidebarBgDark = Color(0xFF111C44);
  static const Color sidebarHoverDark = Color(0xFF1B254B);
  static const Color sidebarActiveDark = primaryDarkTheme;
  static const Color sidebarTextDark = Color(0xFFA3AED0);

  // 3. Semantic Colors
  static const Color success = Color(0xFF05CD99);
  static const Color successLight = Color(0xFFDFF8F1);
  
  static const Color warning = Color(0xFFFFCE20);
  static const Color warningLight = Color(0xFFFFF7DC);
  
  static const Color danger = Color(0xFFEE5D50);
  static const Color dangerLight = Color(0xFFFCEBEA);
  
  static const Color info = Color(0xFF39B8FF);
  static const Color infoLight = Color(0xFFE1F3FF);
  
  static const Color purple = Color(0xFF9065FD);
  static const Color purpleLight = Color(0xFFF0E8FF);

  // 4. Background
  static const Color bgLight = Color(0xFFF4F7FE);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF0B1437);
  static const Color bgDarkCard = Color(0xFF111C44);

  // 5. Text
  static const Color textPrimary = Color(0xFF2B3674);
  static const Color textSecondary = Color(0xFFA3AED0);
  static const Color textLight = Color(0xFFCBD5E1);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color neutral = Color(0xFF6B7280);

  // 6. Borders
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF1B254B);

  // 7. Extra
  static const List<Color> gradientPrimary = [
    Color(0xFF4318FF),
    Color(0xFF7551FF),
  ];

  // 8. Helper methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'active':
      case 'completed':
        return success;
      case 'warning':
      case 'pending':
        return warning;
      case 'danger':
      case 'inactive':
      case 'expired':
      case 'cancelled':
        return danger;
      case 'info':
        return info;
      default:
        return neutral;
    }
  }

  static Color getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'active':
      case 'completed':
        return successLight;
      case 'warning':
      case 'pending':
        return warningLight;
      case 'danger':
      case 'inactive':
      case 'expired':
      case 'cancelled':
        return dangerLight;
      case 'info':
        return infoLight;
      default:
        return borderLight;
    }
  }

  // ─────────────────────────────────────────
  // COMPATIBILITY ALIASES (to avoid breaking changes)
  // ─────────────────────────────────────────
  static const Color border = borderLight;
  static const Color sidebarActiveText = primary;
  static const Color sidebarSection = Color(0xFF8F9BBA);

  static const Color vehicleBg = bgLight;
  static const Color vehicleIcon = primary;
  static const Color driverBg = infoLight;
  static const Color driverIcon = info;
  static const Color reservationBg = warningLight;
  static const Color reservationIcon = warning;
  static const Color ticketBg = dangerLight;
  static const Color ticketIcon = danger;
  static const Color performanceBg = successLight;
  static const Color performanceIcon = success;
  static const Color transferBg = purpleLight;
  static const Color transferIcon = purple;
  static const Color supplyBg = successLight;
  static const Color supplyIcon = success;

  static const Color chartBlue = primary;
  static const Color chartGreen = success;
  static const Color chartRed = danger;
  static const Color chartYellow = warning;
  static const Color chartPurple = purple;
  static const Color chartCyan = info;
}