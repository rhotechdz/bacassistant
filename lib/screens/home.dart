import 'dart:convert';
import 'dart:io';

import 'package:bacassistant/main.dart';
import 'package:bacassistant/routes.dart';
import 'package:bacassistant/services/google_sign_in/auth_service.dart';
import 'package:bacassistant/themes/bloc/theme.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:bacassistant/widgets/wrap_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  BannerAd? bannerAd;
  final countdownKey = GlobalKey<_CountdownCardState>();

  Future<int> _deleteCachedPdfFiles() async {
    final cacheDirectory = Directory('$appStorage/bac_cache');
    if (!await cacheDirectory.exists()) {
      return 0;
    }

    var deletedCount = 0;
    await for (final entity in cacheDirectory.list()) {
      if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
        await entity.delete();
        deletedCount++;
      }
    }
    return deletedCount;
  }

  Future<void> _confirmDeleteCachedFiles() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الملفات المحفوظة'),
        content: const Text(
          'هل تريد حذف ملفات البكالوريا المحفوظة على هذا الجهاز؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final deletedCount = await _deleteCachedPdfFiles();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deletedCount == 0
              ? 'لا توجد ملفات محفوظة للحذف'
              : 'تم حذف $deletedCount من ملفات البكالوريا',
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await prefs.setBool('firstRun', true);
      await AuthService().signOutWithGoogle();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تسجيل الخروج: $error')),
      );
    }
  }

  Future<void> _showFieldPicker() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            'إختر الشعبة',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onPrimaryContainer,
            ),
          ),
        ),
        content: fieldPicker(context, setState),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('الوضع الداكن'),
                trailing: Switch(
                  value: themeState.themeMode == ThemeMode.dark,
                  onChanged: (_) =>
                      context.read<ThemeBloc>().add(ToggleTheme()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('تغيير الشعبة'),
                subtitle: Text(prefs.getString('chosenField') ?? ''),
                onTap: _showFieldPicker,
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('حذف الملفات المحفوظة'),
                subtitle: const Text('حذف ملفات البكالوريا المحفوظة محلياً'),
                onTap: _confirmDeleteCachedFiles,
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('تسجيل الخروج'),
                onTap: _logout,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /* @override
  void initState() {
    super.initState();
    AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate()
    ).then((size) => adSize = size);
    adService.loadAppOpenAd();
    adService.listenToAppStateChanges();
  } */

  /* @override
  void didChangeDependencies() async {
    /* adSize == null
    ? await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate()
    ).then((size) => adSize = size)
    : null; */
    /* adService.loadBannerAd(adSize);
    setState(() {}); */
    super.didChangeDependencies();
  } */

  @override
  void dispose() {
    adService.bannerAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WrapAppBar(
        leftButton: IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'الإعدادات',
          onPressed: _showSettings,
        ),
        rightButton: IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => countdownKey.currentState?.refresh(),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 78, 16, 24),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    context.colors.primary,
                    context.colors.primary.withValues(alpha: 0.78),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.12),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: CountdownCard(key: countdownKey),
            ),
            const SizedBox(height: 12),
            Text(
              'ماذا تريد أن تنجز اليوم؟',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ...pages.asMap().entries.map((entry) {
              final element = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == pages.length - 1 ? 0 : 12,
                ),
                child: _HomeActionCard(
                  title: element['title'] as String,
                  subtitle: _pageSubtitles[element['title']] ?? '',
                  icon: _pageIcons[element['title']] ?? Icons.school_outlined,
                  onTap: () => Navigator.of(context).push(
                    drillDown(element['route'] as Widget),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: adService.bannerAd != null
          ? SizedBox(
              width: adService.bannerAd!.size.width.toDouble(),
              height: adService.bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: adService.bannerAd!),
            )
          : null,
    );
  }
}

const Map<String, IconData> _pageIcons = {
  'بكالوريا سابقة': Icons.menu_book_rounded,
  'اختبر نفسك': Icons.lightbulb_outline_rounded,
  'حساب المعدل': Icons.calculate_rounded,
};

const Map<String, String> _pageSubtitles = {
  'بكالوريا سابقة': 'راجع مواضيع البكالوريا السابقة وحلولها',
  'اختبر نفسك': 'اختبر معلوماتك واستعد للامتحان',
  'حساب المعدل': 'احسب معدلك في البكالوريا بسهولة',
};

class CountdownCard extends StatefulWidget {
  const CountdownCard({super.key});

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  late Future<Map<String, dynamic>> _timestampFuture;

  @override
  void initState() {
    super.initState();
    _timestampFuture = _loadTimestamp();
  }

  Future<Map<String, dynamic>> _loadTimestamp() async {
    final cached = prefs.getString('cached_exam_timestamp');
    if (cached != null && cached.isNotEmpty) {
      final decoded = jsonDecode(cached);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
    }

    final response = await Dio().get(
      'https://bac-assistant.idrismore18.workers.dev/dev/timestamp',
    );
    final data = response.data;
    final normalized = data is Map<String, dynamic>
        ? data
        : (data as Map).cast<String, dynamic>();
    prefs.setString('cached_exam_timestamp', jsonEncode(normalized));
    return normalized;
  }

  void refresh() {
    setState(() => _timestampFuture = _loadTimestamp());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _timestampFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 258,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final examTimestamp = snapshot.data?['examTimestamp'] as int? ?? 0;
        var remainder =
            (examTimestamp - DateTime.now().millisecondsSinceEpoch ~/ 1000)
                .clamp(0, 2147483647);
        final intervals = <String, int>{
          'أشهر': remainder ~/ 2629743,
        };
        remainder %= 2629743;
        intervals['يوم'] = remainder ~/ 86400;
        remainder %= 86400;
        intervals['ساعة'] = remainder ~/ 3600;
        remainder %= 3600;
        intervals['دقيقة'] = remainder ~/ 60;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الوقت المتبقي لامتحان البكالوريا',
                textAlign: TextAlign.right,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.onPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                textDirection: TextDirection.rtl,
                children: intervals.entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color:
                              context.colors.onPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: context.colors.onPrimary
                                .withValues(alpha: 0.16),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${entry.value}',
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: context.colors.onPrimary,
                              ),
                            ),
                            Text(
                              entry.key,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colors.onPrimary
                                    .withValues(alpha: 0.72),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.8),
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: InkWell(
          onTap: onTap,
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? colors.primary.withValues(alpha: 0.08)
                : null,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            leading: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: colors.onPrimaryContainer,
                size: 28,
              ),
            ),
            title: Text(
              title,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            subtitle: Text(
              subtitle,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
