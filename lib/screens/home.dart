import 'dart:convert';
import 'dart:io';

import 'package:bacassistant/main.dart';
import 'package:bacassistant/routes.dart';
import 'package:bacassistant/themes/bloc/theme.dart';
import 'package:bacassistant/utils/initializer.dart';
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
  int? timestamp;
  Duration? diff;
  Map intervals = {};
  BannerAd? bannerAd;

  Future<Map<String, dynamic>> _loadTimestamp() async {
    final cached = prefs.getString('cached_exam_timestamp');
    if (cached != null && cached.isNotEmpty) {
      final decoded = jsonDecode(cached);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
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
      appBar: AppBar(
        primary: true,
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'الإعدادات',
          onPressed: _showSettings,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () async {
                  setState(() {});
                }),
          ),
        ],
      ),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                    context.colors.primaryContainer,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: FutureBuilder<Object>(
                  future: _loadTimestamp().then((value) {
                    final examTimestamp = value['examTimestamp'] as int? ?? 0;
                    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                    final diff = (examTimestamp - now).clamp(0, 2147483647);

                    int remainder = diff;
                    intervals['أشهر'] = (remainder ~/ 2629743);
                    remainder = remainder.remainder(2629743);
                    intervals['يوم'] = (remainder ~/ 86400);
                    remainder = remainder.remainder(86400);
                    intervals['ساعة'] = (remainder ~/ 3600);
                    remainder = remainder.remainder(3600);
                    intervals['دقيقة'] = (remainder ~/ 60);

                    return 0;
                  }),
                  builder: (context, snapshot) {
                    Widget buildWidget = Container(
                      height: 238,
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: context.colors.onPrimary,
                        ),
                      ),
                    );
                    if (snapshot.connectionState == ConnectionState.done) {
                      buildWidget = Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: context.colors.onPrimary
                                        .withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.event_available_rounded,
                                    color: context.colors.onPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'الوقت المتبقي',
                                    textAlign: TextAlign.right,
                                    style:
                                        context.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'استمر في التقدم، كل يوم يقربك من هدفك',
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onPrimary
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              textDirection: TextDirection.rtl,
                              children: intervals.entries.map((entry) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: context.colors.surface
                                            .withValues(alpha: 0.86),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${entry.value}',
                                            style: context
                                                .textTheme.headlineMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: context.colors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            entry.key,
                                            style: context.textTheme.labelMedium
                                                ?.copyWith(
                                              color: context
                                                  .colors.onSurfaceVariant
                                                  .withValues(alpha: 0.75),
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
                    }

                    return buildWidget;
                  }),
            ),
            Text(
              'ماذا تريد أن تنجز اليوم؟',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final element = pages[index];
                return _HomeActionCard(
                  title: element['title'] as String,
                  icon: _pageIcons[element['title']] ?? Icons.school_outlined,
                  onTap: () => Navigator.of(context).push(
                    drillDown(element['route'] as Widget),
                  ),
                );
              },
            ),
          ]),
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
  'المقرر الدراسي': Icons.auto_stories_rounded,
  'إختبار الحفظ': Icons.lightbulb_outline_rounded,
  'حساب المعدل': Icons.calculate_rounded,
};

class _HomeActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? colors.primary.withValues(alpha: 0.08)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_outward_rounded,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: colors.onPrimaryContainer,
                  size: 30,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
