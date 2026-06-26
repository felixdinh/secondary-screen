import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secondary_screen/secondary_screen.dart';

import 'order_display_screen.dart';
import 'promotion_screen.dart';
import 'sales_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const SalesScreen());
    case 'sales':
      return MaterialPageRoute(builder: (_) => const SalesScreen());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const PromotionScreen());
    case 'order_display':
      return MaterialPageRoute(builder: (_) => const OrderDisplayScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

void main() {
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void secondaryDisplayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MySecondApp());
}

class MySecondApp extends StatelessWidget {
  const MySecondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: 'presentation',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SecondaryScreenScope(
      autoShow: true,
      defaultRouteName: 'presentation',
      child: MaterialApp(
        onGenerateRoute: generateRoute,
        initialRoute: 'sales',
      ),
    );
  }
}
