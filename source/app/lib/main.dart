import 'package:app/ui/admin/screens/dashboard_screen.dart';
import 'package:app/ui/order/payment_success.dart';
import 'package:app/ui/product_details.dart';
import 'package:app/ui/screens/shopping_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'ui/main_page.dart';
import 'ui/login/login_page.dart';
import 'ui/login/verify_otp_register.dart';
import 'ui/order/payment_process.dart';
import 'ui/product_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ecommerce App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/main': (context) => MainPage(),
          '/manager': (context) => DashboardScreen(),
          '/login': (context) => LoginPage(),
          '/otp': (context) => VerifyOtpScreen(),
          '/cart': (context) => ShoppingCartPage(),
          '/success': (context) => PaymentSuccessScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/animation.json', width: 200),
            SizedBox(height: 15),
            Text(
              "TechZone",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
