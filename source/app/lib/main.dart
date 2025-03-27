import 'package:app/ui/login/Payment.dart';
import 'package:app/ui/login/VerificationCodeScreen.dart';
import 'package:app/ui/main_page.dart';
import 'package:app/ui/payment_success.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '/ui/login/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/login': (context) => LoginPage(),
          '/': (context) => MainPage(),
          '/otp': (context) => VerifyOtpScreen(),
          '/payment': (context) => PaymentConfirmationScreen(),
        },
      ),
    );
  }
}
