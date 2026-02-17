import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart'; // ← your AppColor

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final double elevation;
  final double bottomRadius;
  final bool hasGradient;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.elevation = 0.0,
    this.bottomRadius = 32.0,
    this.hasGradient = true,
    this.gradientColors,
    this.gradientStops,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradientColors = gradientColors ??
        [
          const Color(0xFF6A1B9A), // deep purple
          const Color(0xFF9C27B0), // vibrant
          const Color(0xFFAB47BC), // soft end
        ];

    final defaultStops = gradientStops ?? [0.0, 0.6, 1.0];

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 23,
          letterSpacing: 0.4,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 28,
        shadows: [
          Shadow(
            color: Colors.black38,
            blurRadius: 4,
            offset: Offset(1, 1),
          ),
        ],
      ),
      leading: leading ??
          (Navigator.canPop(context)
              ? IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          )
              : null),
      actions: actions,
      flexibleSpace: hasGradient
          ? Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: defaultGradientColors,
            stops: defaultStops,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
        ),
      )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}