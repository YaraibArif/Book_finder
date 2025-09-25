import 'package:book_finder/providers/favorites_provider.dart';
import 'package:book_finder/providers/search_provider.dart';
import 'package:book_finder/providers/subject_provider.dart';
import 'package:book_finder/respositories/favorites_repository.dart';
import 'package:book_finder/respositories/subject_repository.dart';
import 'package:book_finder/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => SubjectProvider(repository: SubjectRepository()),
        ),
        ChangeNotifierProvider(create: (_) => SearchProvider()),

        /// ✅ Favorites depends on AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider?>(
          create: (_) => null,
          update: (_, auth, prev) {
            if (auth.isSignedIn && auth.userId != null) {
              if (prev != null && prev.userId == auth.userId) {
                return prev;
              }
              // 👇 yahan repository inject karna hai
              return FavoritesProvider(
                repository: FavoritesRepository(),
                userId: auth.userId!,
              );
            }
            return null;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Book Finder",
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}
