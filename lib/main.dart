import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'package:laptopharbor/ui/screens/auth/admin_login_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'ui/screens/auth/splash_screen.dart';
import 'services/cart_service.dart';
import 'providers/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const LaptopHarborApp(),
    ),
  );
}

class LaptopHarborApp extends StatelessWidget {
  const LaptopHarborApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Firebase Auth user ko listen karega
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),

        // Yahan CartProvider initialize ho raha hai
        ChangeNotifierProxyProvider<User?, CartProvider>(
          create: (_) => CartProvider(CartService(), ""),
          update: (_, user, previous) {
            final uid = user?.uid ?? "";
            return CartProvider(CartService(), uid);
          },
        ),
      ],
      child: MaterialApp(
        title: 'LaptopHarbor',
        debugShowCheckedModeBanner: false,

        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light,
        ),
        home: const SplashScreen(),
        // home: const AdminLoginScreen(),
      ),
    );
  }
}
