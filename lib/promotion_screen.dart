import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presentation_displays/secondary_display.dart';
import 'package:secondary_screen/widgets/carousel_indicator.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final  _controller = CarouselSliderController();
  static const Duration _slideInterval = Duration(seconds: 5);
  static const Duration _fadeDuration = Duration(milliseconds: 150);
  int _currentIndex = 0;  
  final List<String> _imageUrls = const [
    'https://filmciti.com.vn/wp-content/uploads/2022/03/quang-cao-vinamilk-2.jpg',
    'https://rgb.vn/wp-content/uploads/2025/01/celano-hieuthuhai.png',
    'https://newfreshmart.com.vn/contents_images/images/Kem/kem-celano-1.png',
  ];

  @override
  void initState() {
    super.initState();
  
  }

  @override
  void dispose() {
    // Restore orientations and system UI when leaving this screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SecondaryDisplay(
        callback: (args) {
          debugPrint('display: $args');
        },
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            CarouselSlider.builder(
              carouselController: _controller,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index, realIndex) => _buildImage(_imageUrls[index], index),
              disableGesture: true,
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: _slideInterval,
                autoPlayAnimationDuration: _fadeDuration,
                autoPlayCurve: Curves.easeInOut,
                enableInfiniteScroll: true,
                viewportFraction: 1.0,
                disableCenter: true,
                
                // aspectRatio: 16 / 9,
                //enlargeCenterPage: false,
                //enlargeStrategy: CenterPageEnlargeStrategy.height,
                onPageChanged: (index, reason) {  
                    setState(() {
                      _currentIndex = index;
                    });
        
                },   
                scrollPhysics: const NeverScrollableScrollPhysics(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: CarouselIndicator(
                  currentPageIndex: _currentIndex,
                  itemCount: _imageUrls.length,
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Colors.grey,
                  width: 64,
                  height: 16,
                  borderRadius: 16,
                  spacing: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url, int index) {
    return Container(
      key: ValueKey<int>(index),
      color: Colors.black,
      alignment: Alignment.center,
      child: CachedNetworkImage(
        imageUrl: url,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
        errorWidget: (context, url, error) => Center(
          child: Icon(Icons.broken_image, color: Colors.white70, size: 48),
        ),
      ),
    );
  }
}


