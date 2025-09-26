import 'dart:async';
import 'package:flutter/material.dart';
import 'package:presentation_displays/secondary_display.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class LandscapePromotionScreen extends StatelessWidget {
  const LandscapePromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: const PromotionScreen(),
    );
  }
}

class _PromotionScreenState extends State<PromotionScreen> {
  static const Duration _slideInterval = Duration(seconds: 10);
  static const Duration _fadeDuration = Duration(milliseconds: 150);

  final List<String> _imageUrls = const [
    'https://filmciti.com.vn/wp-content/uploads/2022/03/quang-cao-vinamilk-2.jpg',
    'https://rgb.vn/wp-content/uploads/2025/01/celano-hieuthuhai.png',
    'https://bestplus.vn/Userfiles/Upload/images/A%20best%20o.jpg',
  ];

  late Timer _timer;
  int _currentIndex = 0;
   String value = "init";

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(_slideInterval, (_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _imageUrls.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SecondaryDisplay(
        callback: (display) {
          debugPrint('display: $display');
          setState(() {
            value = display;
          });
        },
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: _fadeDuration,
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: _buildImage(_imageUrls[_currentIndex], _currentIndex),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url, int index) {
    return Container(
      key: ValueKey<int>(index),
      color: Colors.black,
      alignment: Alignment.center,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white70),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white70, size: 48),
        ),
      ),
    );
  }
}


