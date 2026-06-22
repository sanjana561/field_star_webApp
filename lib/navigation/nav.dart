import 'dart:async';
import 'package:field_star/Analytics/analytics.dart';
import 'package:field_star/navigation/shellPage.dart';
import 'package:field_star/pages/Technician/technician.dart';
import 'package:field_star/pages/billing&payments/billing&payments.dart';
import 'package:field_star/pages/complaints/complaints.dart';
import 'package:field_star/pages/customer/customer.dart';
import 'package:field_star/pages/overview/overview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';




final GoRouter appRouter = GoRouter(
  initialLocation: '/Dashboard',
  // refreshListenable: GoRouterRefreshStream(
  //   supabase.auth.onAuthStateChange,
  // ),
  // redirect: (context, state) {
  //   final session = supabase.auth.currentSession;
  //   final loggedIn = session != null;
  //   final isLogin = state.uri.path == '/login';

  //   if (!loggedIn && !isLogin) return '/login';

  //   return null;
  // },
  routes: [
    // GoRoute(
    //   path: '/login',
    //   builder: (context, state) => const LoginPage(),
    // ),

    ShellRoute(
      builder: (context, state, child) => ShellPage(
        key: state.pageKey,
        child: child,
      ),
      routes: [
    GoRoute(
  path: '/Dashboard',
  builder: (context, state) {
    // ✅ Handle both int and String extras safely
    final extra = state.extra;
    
    String technicianId = '';
    
    if (extra is int) {
      technicianId = extra.toString();
    } else if (extra is String) {
      technicianId = extra;
    } else if (extra != null) {
      technicianId = extra.toString();
    }

    return Overview(
      technicianId: technicianId,
    );
  },
),
          GoRoute(
          path: '/Technicians',
           builder: (context, state) => const Technician(),
          
        ),
          GoRoute(
          path: '/Complaints',
           builder: (context, state) => const Complaints(),
          
        ),
          GoRoute(
          path: '/Customers',
           builder: (context, state) => const Customer(),
          
        ),
          GoRoute(
          path: '/Billing',
           builder: (context, state) => const Billingpayments(),
          
        ),
         GoRoute(
          path: '/Analytics',
           builder: (context, state) => const Analytics(),
          
        ),

        // GoRoute(
        //   path: '/enquiries/:businessId',
        //   builder: (context, state) {
        //     final businessId =
        //         int.parse(state.pathParameters['businessId']!);

        //     return Enquires(
        //       businessId: businessId,
        //     );
        //   },
        // ),

        // GoRoute(
        //   path: '/followups/:businessId',
        //   builder: (context, state) {
        //     final businessId =
        //         int.parse(state.pathParameters['businessId']!);

        //     return Followup(
        //       businessId: businessId,
        //     );
        //   },
        // ),

        // GoRoute(
        //   path: '/channels/:businessId',
        //   builder: (context, state) {
        //     final businessId =
        //         int.parse(state.pathParameters['businessId']!);

        //     return Channels(
        //       businessId: businessId,
        //     );
        //   },
        // ),

        // GoRoute(
        //   path: '/reports/:businessId',
        //   builder: (context, state) {
        //     final businessId =
        //         int.parse(state.pathParameters['businessId']!);

        //     return Report(
        //       businessId: businessId,
        //     );
        //   },
        // ),
      ],
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}