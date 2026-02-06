import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/auth_provider.dart';
import 'providers/moong_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/quest_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/inventory_provider.dart';
import 'services/migration_service.dart';
import 'services/seed_data_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/moong_select_screen.dart';
import 'screens/garden_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/main_moong_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/food_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/shop_category_screen.dart';
import 'models/shop_item.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/background_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/moong_choice_screen.dart';
import 'screens/quest_completed_screen.dart';
import 'screens/intimacy_up_screen.dart';
import 'screens/archive_main_screen.dart';
import 'screens/emotion_analysis_screen.dart';
import 'screens/credit_info_1_screen.dart';
import 'screens/credit_info_2_screen.dart';
import 'screens/credit_refund_screen.dart';
import 'screens/onboarding_animation_screen.dart';
import 'screens/logo_animation_screen.dart';
import 'screens/music_generation_screen.dart';
import 'screens/exercise_suggestion_screen.dart';
import 'screens/food_suggestion_screen.dart';
import 'screens/chat_input_screen.dart';
import 'screens/credit_balance_screen.dart';
import 'screens/sad_moong_screen.dart';
import 'screens/garden_view_screen.dart';
import 'screens/cute_moong_screen.dart';
import 'screens/forest_background_screen.dart';
import 'screens/beach_background_screen.dart';
import 'screens/space_background_screen.dart';
import 'screens/sakura_background_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite for desktop platforms only
  // Web is not supported for SQLite yet - needs alternative implementation
  if (!kIsWeb) {
    // For desktop (macOS, Windows, Linux)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Run migration and seeding only on non-web platforms
  if (!kIsWeb) {
    // Run migration from SharedPreferences to SQLite
    final migrationService = MigrationService();
    try {
      await migrationService.migrateFromSharedPreferences();
    } catch (e) {
      debugPrint('Migration error: $e');
    }
    
    // Seed initial data (shop items)
    final seedDataService = SeedDataService();
    try {
      await seedDataService.seedShopItems();
    } catch (e) {
      debugPrint('Seed data error: $e');
    }
  } else {
    debugPrint('Running on web - SQLite features disabled');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoongProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => QuestProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: Builder(
        builder: (context) => const _AppInitializer(),
      ),
    );
  }
}

class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    // Wait for AuthProvider to load user data
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moongProvider = Provider.of<MoongProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    // Initialize shop items (available regardless of login)
    await shopProvider.initialize();

    // If user is already logged in, initialize user-dependent providers
    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.id;
      await moongProvider.initialize(userId);
      await inventoryProvider.initialize(userId);

      if (!mounted) return;
      final questProvider = Provider.of<QuestProvider>(context, listen: false);
      await questProvider.initialize(userId);

      if (!mounted) return;
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (moongProvider.activeMoong != null) {
        await chatProvider.initialize(
          authProvider.currentUser!.id,
          moongProvider.activeMoong!.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moong App',
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false, // Semantics 활성화 (테스트용)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC76F69)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/moong-select': (context) => const MoongSelectScreen(),
          '/garden': (context) => const GardenScreen(),
          '/shop': (context) => const ShopScreen(),
          '/main': (context) => const MainMoongScreen(),
          '/quest': (context) => const QuestScreen(),
          '/food': (context) => const FoodScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/chat': (context) => const ChatScreen(),
          '/chat-detail': (context) => const ChatDetailScreen(),
          '/archive': (context) => const ArchiveScreen(),
          '/signup': (context) => const SignupScreen(),
          '/profile-edit': (context) => const ProfileEditScreen(),
          '/background': (context) => const BackgroundScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/moong-choice': (context) => const MoongChoiceScreen(),
          '/quest-completed': (context) => const QuestCompletedScreen(),
          '/intimacy-up': (context) => const IntimacyUpScreen(),
          '/archive-main': (context) => const ArchiveMainScreen(),
          '/emotion-analysis': (context) => const EmotionAnalysisScreen(),
          '/credit-info-1': (context) => const CreditInfo1Screen(),
          '/credit-info-2': (context) => const CreditInfo2Screen(),
          '/credit-refund': (context) => const CreditRefundScreen(),
          '/onboarding-animation': (context) => const OnboardingAnimationScreen(),
          '/logo-animation': (context) => const LogoAnimationScreen(),
          '/music-generation': (context) => const MusicGenerationScreen(),
          '/exercise-suggestion': (context) => const ExerciseSuggestionScreen(),
          '/food-suggestion': (context) => const FoodSuggestionScreen(),
          '/chat-input': (context) => const ChatInputScreen(),
          '/credit-balance': (context) => const CreditBalanceScreen(),
          '/sad-moong': (context) => const SadMoongScreen(),
          '/garden-view': (context) => const GardenViewScreen(),
          '/cute-moong': (context) => const CuteMoongScreen(),
          '/background-forest': (context) => const ForestBackgroundScreen(),
          '/background-beach': (context) => const BeachBackgroundScreen(),
          '/background-space': (context) => const SpaceBackgroundScreen(),
        '/background-sakura': (context) => const SakuraBackgroundScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/shop-category/') ?? false) {
          final categoryStr = settings.name!.split('/').last;
          final category = ShopCategory.values.firstWhere(
            (e) => e.name == categoryStr,
            orElse: () => ShopCategory.accessories,
          );
          return MaterialPageRoute(
            builder: (context) => ShopCategoryScreen(category: category),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        debugPrint('Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      },
    );
  }
}

