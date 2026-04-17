import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'core/utils/label_mapper.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TFLite etiketlerini cihaz hafızasına ilk saniyede alır
  await LabelMapper.loadLabels();

  // Tüm uygulamayı Riverpod beynine (ProviderScope) bağladık
  runApp(const ProviderScope(child: HearMeOutApp()));
}

class HearMeOutApp extends ConsumerWidget {
  const HearMeOutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider).themeMode;
    return MaterialApp.router(
      title: 'Hear Me Out',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Profil sayfasındaki tema seçimini yansıtır
      routerConfig: router,
    );
  }
}
