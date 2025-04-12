import 'package:app/services/api_service.dart';
import 'package:app/ui/admin/screens/dashboard_screen.dart';
import 'package:app/ui/login/update_address_page.dart';
import 'package:app/ui/order/payment_success.dart';
import 'package:app/ui/product_details.dart';
import 'package:app/ui/profile/address_list_screen.dart';
import 'package:app/ui/screens/shopping_page.dart';
import 'package:dio/dio.dart';
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: LoginPage(),
      // home: PaymentConfirmationScreen(),
      // home: ChangePasswordScreen(),
      // home: UserInfoScreen(),
      home: UpdateAddressScreen(currentAddress: ''),
    );
  }
}
