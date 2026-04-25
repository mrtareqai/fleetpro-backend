import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';

class FleetProApp extends ConsumerWidget {
  const FleetProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FleetPro Management',
      debugShowCheckedModeBanner: false,
      theme: isDark
          ? AppTheme.dark(locale: locale)
          : AppTheme.light(locale: locale),
      routerConfig: router,
      locale: Locale(locale),
      builder: (context, child) {
        return Directionality(
          textDirection:
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
