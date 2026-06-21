import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellPage extends StatelessWidget {
  final Widget child;

  const ShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Determine which tab is selected based on the current URL
    final String location = GoRouterState.of(context).uri.path;
    
    

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Row(
        children: [
          Expanded(
            child: ClipRRect(
              // Adds a nice rounded feel to the content area
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                bottomLeft: Radius.circular(32),
              ),
              child: Container(
                color: Colors.white,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}