import 'package:flutter/material.dart';

class CarouselIndicator extends StatelessWidget {
  const CarouselIndicator({
    super.key,
    required this.currentPageIndex,
    required this.itemCount,
    required this.activeColor,
    required this.inactiveColor,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.spacing,
  });
  final int currentPageIndex;
  final int itemCount;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final double borderRadius;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: spacing,
      children: [
        for (int i = 0; i < itemCount; i++)
          _DotIndicator(
            width: height,
            activeWidth: width,
            height: height,
            color: inactiveColor,
            borderRadius: borderRadius,
            isActive: i == currentPageIndex,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
      ],
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator(
      {required this.width,
      required this.activeWidth,
      required this.height,
      required this.color,
      required this.borderRadius,
      required this.isActive,
      required this.activeColor,
      required this.inactiveColor});
  final double width;
  final double activeWidth;
  final double height;
  final Color color;
  final double borderRadius;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isActive ? activeWidth : width,
      height: height,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
