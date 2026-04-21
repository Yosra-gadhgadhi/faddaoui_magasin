// import 'package:flutter/material.dart';
// import 'package:elfaddoui_app/features/auth/presentation/screens/forgot_password_screen.dart';
// import 'package:elfaddoui_app/features/auth/presentation/screens/otp_screen.dart';
// import 'package:elfaddoui_app/features/auth/presentation/screens/reset_password_screen.dart';
// import 'package:elfaddoui_app/features/auth/presentation/screens/sign_up_screen.dart';
// import 'package:elfaddoui_app/features/auth/presentation/screens/sign_in_screen.dart';
// import 'package:elfaddoui_app/features/home/presentation/screens/home_screen.dart';
// import 'package:elfaddoui_app/features/catalog/presentation/screens/categories_screen.dart';
// import 'package:elfaddoui_app/features/catalog/presentation/screens/product_list_screen.dart';
// import 'package:elfaddoui_app/features/catalog/presentation/screens/product_details_screen.dart';
// import 'package:elfaddoui_app/features/cart/presentation/screens/cart_screen.dart';
// import 'package:elfaddoui_app/features/profile/presentation/screens/profile_screen.dart';
// import 'package:elfaddoui_app/features/catalog/presentation/screens/search_screen.dart';

// class AppRoutes {
//   static const signIn = '/sign-in';
//   static const signUp = '/sign-up';
//   static const forgot = '/forgot';
//   static const otp = '/otp';
//   static const resetPassword = '/reset-password';
//   static const home = '/'; // Changed to '/' for the initial route
//   static const categories = '/categories';
//   static const productList = '/product-list';
//   static const productDetails = '/product-details';
//   static const cart = '/cart';
//   static const profile = '/profile';
//   static const search = '/search';

//   static Map<String, WidgetBuilder> get routes => {
//         signIn: (_) => const SignInScreen(),
//         signUp: (_) => const SignUpScreen(),
//         otp: (_) => const OtpScreen(),
//         resetPassword: (_) => const ResetPasswordScreen(),
//         forgot: (_) => const ForgotPasswordScreen(),
//         home: (_) => const HomeScreen(), // Use the actual HomeScreen
//         categories: (_) => const CategoriesScreen(),
//         productList: (_) => const ProductListScreen(),
//         productDetails: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments as String?;
//           return ProductDetailsScreen(productId: args ?? '1'); // Default to '1' if no ID
//         },
//         cart: (_) => const CartScreen(),
//         profile: (_) => const ProfileEditScreen(),
//         search: (_) => const SearchScreen(),
//       };
// }

import 'package:flutter/material.dart';

import 'package:elfaddoui_app/main_nav_screen.dart';

// Auth screens
import 'package:elfaddoui_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/phone_otp_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:elfaddoui_app/features/auth/presentation/screens/reset_password_screen.dart';

// App screens (optional named routes)
import 'package:elfaddoui_app/features/home/presentation/screens/home_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/categories_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/product_list_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/product_details_screen.dart';
import 'package:elfaddoui_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:elfaddoui_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:elfaddoui_app/features/profile/presentation/screens/about_store_screen.dart';
import 'package:elfaddoui_app/features/profile/presentation/screens/loyalty_card_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/search_screen.dart';
import 'package:elfaddoui_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:elfaddoui_app/features/delivery/presentation/screens/delivery_tracking_screen.dart';
import 'package:elfaddoui_app/features/settings/presentation/screens/settings_screen.dart';

class AppRoutes {
  // Auth
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgot = '/forgot';
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const phoneAuth = '/phone-auth';
  static const phoneOtp = '/phone-otp';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';

  // Main tabs (after login)
  static const main = '/main';

  // Optional other routes (if you use them)
  static const home = '/home';
  static const categories = '/categories';
  static const productList = '/product-list';
  static const productDetails = '/product-details';
  static const cart = '/cart';
  static const profile = '/profile';
  static const search = '/search';
  static const notifications = '/notifications';
  static const deliveryTracking = '/delivery-tracking';
  static const aboutStore = '/about-store';
  static const loyaltyCard = '/loyalty-card';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        // ✅ Auth
        splash: (_) => const SplashScreen(),
        welcome: (_) => const WelcomeScreen(),
        signIn: (_) => const SignInScreen(),
        signUp: (_) => const SignUpScreen(),
        forgot: (_) => const ForgotPasswordScreen(),
        onboarding: (_) => const OnboardingScreen(),
        phoneAuth: (_) => const PhoneAuthScreen(),
        phoneOtp: (_) => const PhoneOtpScreen(),
        otp: (_) => const OtpScreen(),
        resetPassword: (_) => const ResetPasswordScreen(),

        // ✅ Main (tabs)
        main: (_) => const MainNavScreen(),

        // Optional screens
        home: (_) => const HomeScreen(),
        categories: (_) => const CategoriesScreen(),
        productList: (_) => const ProductListScreen(),

        // ✅ Product Details with args
        productDetails: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return ProductDetailsScreen(productId: args ?? '1');
        },

        cart: (_) => const CartScreen(),
        profile: (_) => const ProfileEditScreen(),
        search: (_) => const SearchScreen(),
        notifications: (_) => const NotificationsScreen(),
        deliveryTracking: (_) => const DeliveryTrackingScreen(),
        aboutStore: (_) => const AboutStoreScreen(),
        loyaltyCard: (_) => const LoyaltyCardScreen(),
        settings: (_) => const SettingsScreen(),
      };
}
