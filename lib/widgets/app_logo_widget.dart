import 'package:flutter/material.dart';

class AppLogoWidget extends StatelessWidget {
  final double height;
  final double? width;
  final bool showShadow;

  const AppLogoWidget({
    super.key,
    this.height = 100,
    this.width,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            )
          : null,
      child: Image.asset(
        'assets/images/app_logo.png',
        height: height,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
