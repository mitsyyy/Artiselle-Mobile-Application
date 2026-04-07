import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/buyer/home_screen.dart';
import '../screens/buyer/search_screen.dart';
import '../screens/buyer/product_detail_screen.dart';
import '../screens/buyer/cart_screen.dart';
import '../screens/buyer/checkout_screen.dart';
import '../screens/buyer/order_confirmation_screen.dart';
import '../screens/buyer/orders_screen.dart';
import '../screens/buyer/order_detail_screen.dart';
import '../screens/buyer/store_profile_screen.dart';
import '../screens/buyer/write_review_screen.dart';
import '../screens/seller/seller_dashboard_screen.dart';
import '../screens/seller/manage_store_screen.dart';
import '../screens/seller/product_list_screen.dart';
import '../screens/seller/add_edit_product_screen.dart';
import '../screens/seller/seller_orders_screen.dart';
import '../screens/seller/seller_order_detail_screen.dart';
import '../screens/seller/sales_report_screen.dart';
import '../screens/shared/account_settings_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const buyerHome = '/buyer/home';
  static const sellerHome = '/seller/home';
  static const search = '/buyer/search';
  static const productDetail = '/buyer/product';
  static const cart = '/buyer/cart';
  static const checkout = '/buyer/checkout';
  static const orderConfirmation = '/buyer/order-confirmation';
  static const orders = '/buyer/orders';
  static const orderDetail = '/buyer/order-detail';
  static const storeProfile = '/buyer/store';
  static const writeReview = '/buyer/write-review';
  static const accountSettings = '/account/settings';
  // Seller routes
  static const manageStore = '/seller/store';
  static const sellerProducts = '/seller/products';
  static const addEditProduct = '/seller/product/edit';
  static const sellerOrders = '/seller/orders';
  static const sellerOrderDetail = '/seller/order-detail';
  static const salesReport = '/seller/sales-report';
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.register:
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case AppRoutes.forgotPassword:
      return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
    case AppRoutes.buyerHome:
      return MaterialPageRoute(builder: (_) => const BuyerHomeScreen());
    case AppRoutes.sellerHome:
      return MaterialPageRoute(builder: (_) => const SellerDashboardScreen());
    case AppRoutes.search:
      return MaterialPageRoute(builder: (_) => const SearchScreen());
    case AppRoutes.productDetail:
      final id = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: id));
    case AppRoutes.cart:
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case AppRoutes.checkout:
      return MaterialPageRoute(builder: (_) => const CheckoutScreen());
    case AppRoutes.orderConfirmation:
      final id = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => OrderConfirmationScreen(orderId: id));
    case AppRoutes.orders:
      return MaterialPageRoute(builder: (_) => const OrdersScreen());
    case AppRoutes.orderDetail:
      final id = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id));
    case AppRoutes.storeProfile:
      final id = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => StoreProfileScreen(sellerId: id));
    case AppRoutes.writeReview:
      final args = settings.arguments as Map<String, String>;
      return MaterialPageRoute(
        builder: (_) => WriteReviewScreen(
          productId: args['productId']!,
          orderId: args['orderId']!,
        ),
      );
    case AppRoutes.accountSettings:
      return MaterialPageRoute(builder: (_) => const AccountSettingsScreen());
    // Seller
    case AppRoutes.manageStore:
      return MaterialPageRoute(builder: (_) => const ManageStoreScreen());
    case AppRoutes.sellerProducts:
      return MaterialPageRoute(builder: (_) => const SellerProductListScreen());
    case AppRoutes.addEditProduct:
      final id = settings.arguments as String?;
      return MaterialPageRoute(builder: (_) => AddEditProductScreen(productId: id));
    case AppRoutes.sellerOrders:
      return MaterialPageRoute(builder: (_) => const SellerOrdersScreen());
    case AppRoutes.sellerOrderDetail:
      final id = settings.arguments as String;
      return MaterialPageRoute(
          builder: (_) => SellerOrderDetailScreen(orderId: id));
    case AppRoutes.salesReport:
      return MaterialPageRoute(builder: (_) => const SalesReportScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
