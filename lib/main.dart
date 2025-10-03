// import 'package:flutter/material.dart';
// import 'package:secondary_screen/home_screen.dart';
// import 'package:secondary_screen/promotion_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// @pragma('vm:entry-point')
// void secondaryDisplayMain() {
//   debugPrint('second main');
//   runApp(const SecondaryApp());
// }


// Route<dynamic> generateRoute(RouteSettings settings) {
//   switch (settings.name) {
//     case '/':
//       return MaterialPageRoute(builder: (_) => const HomeScreen());
//     case 'presentation':
//       return MaterialPageRoute(builder: (_) => const PromotionScreen());
//     default:
//       return MaterialPageRoute(
//           builder: (_) => Scaffold(
//                 body: Center(
//                     child: Text('No route defined for ${settings.name}')),
//               ));
//   }
// }




// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

  
//   @override
//   Widget build(BuildContext context) {
//    return const MaterialApp(
//       onGenerateRoute: generateRoute,
//       initialRoute: '/',
//     );
//   }
// }

// class SecondaryApp extends StatelessWidget {
//   const SecondaryApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//    return const MaterialApp(
//       onGenerateRoute: generateRoute,
//       initialRoute: 'presentation',

//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:presentation_displays/secondary_display.dart';
import 'package:secondary_screen/promotion_screen.dart';
import 'package:secondary_screen/dual_screen_service/src/dual_screen_service.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const DisplayManagerScreen());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const PromotionScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

void main() {
  debugPrint('first main');
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
      
  debugPrint('second main');
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
    return BlocProvider(
      create: (context) => DualScreenCubit(),
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        initialRoute: '/',
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const Button({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}

/// Main Screen
class DisplayManagerScreen extends StatefulWidget {
  const DisplayManagerScreen({super.key});

  @override
  State<DisplayManagerScreen> createState() => _DisplayManagerScreenState();
}

class _DisplayManagerScreenState extends State<DisplayManagerScreen> {
  DisplayManager displayManager = DisplayManager();
  List<Display?> displays = [];

  final TextEditingController _indexToShareController = TextEditingController();
  final TextEditingController _dataToTransferController =
      TextEditingController();

  final TextEditingController _nameOfIdController = TextEditingController();
  String _nameOfId = "";
  final TextEditingController _nameOfIndexController = TextEditingController();
  String _nameOfIndex = "";

  @override
  void initState() {
    displayManager.connectedDisplaysChangedStream?.listen(
      (event) {
        debugPrint("connected displays changed: $event");
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Show current state of SecondaryScreenCubit
              BlocBuilder<DualScreenCubit, DualScreenState>(
                builder: (context, state) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Secondary Screen Status: ${state.status.name}'),
                          Text('Current Display ID: ${state.defaultSecondaryDisplayId ?? 'None'}'),
                          Text('Current Route: ${state.currentRoute ?? 'None'}'),
                          Text('Is Loading: ${state.isLoading}'),
                          if (state.error != null) Text('Error: ${state.error}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _getDisplays(),
              _initSecondaryScreen(),
              _showPresentation(),
              _hidePresentation(),
              _transferData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDisplays() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Button(
            title: "Get Displays",
            onPressed: () async {
              final values = await displayManager.getDisplays();
              displays.clear();
              setState(() {
                displays.addAll(values!);
              });
            }),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: displays.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 50,
                child: Center(
                    child: Text(
                        ' ${displays[index]?.displayId} ${displays[index]?.name}')),
              );
            }),
        const Divider()
      ],
    );
  }

  Widget _initSecondaryScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Button(
            title: "Initialize Secondary Screen Service",
            onPressed: () async {
              final cubit = context.read<DualScreenCubit>();
              await cubit.init(autoShow: true, defaultRouterName: 'presentation');
            }),
        Button(
            title: "Show on Secondary (Cubit)",
            onPressed: () async {
              final cubit = context.read<DualScreenCubit>();
              await cubit.showOnSecondary('presentation', data: {'message': 'Hello from Cubit!'});
            }),
        Button(
            title: "Update Data on Secondary (Cubit)",
            onPressed: () async {
              final cubit = context.read<DualScreenCubit>();
              await cubit.updateDataOnSecondary({'message': 'Updated data from Cubit!'});
            }),
        const Divider(),
      ],
    );
  }

  Widget _showPresentation() {
    return Button(
        title: "Show current display",
        onPressed: () async {
          final cubit = context.read<DualScreenCubit>();
          await cubit.showOnSecondary('presentation');
        });
  }

  Widget _hidePresentation() {
    return Button(
        title: "Hide presentation",
        onPressed: () async {
          final cubit = context.read<DualScreenCubit>();
          await cubit.hideOnSecondary(clearData: true);
        });
  }

  Widget _transferData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _dataToTransferController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Data to transfer',
            ),
          ),
        ),
        Button(
            title: "TransferData",
            onPressed: () async {
              String data = _dataToTransferController.text;
              await displayManager.transferDataToPresentation(data);
            }),
        const Divider(),
      ],
    );
  }
}

/// UI of Presentation display
class SecondaryScreen extends StatefulWidget {
  const SecondaryScreen({super.key});

  @override
  State<SecondaryScreen> createState() => _SecondaryScreenState();
}

class _SecondaryScreenState extends State<SecondaryScreen> {
  String value = "init";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SecondaryDisplay(
      callback: (dynamic argument) {
        setState(() {
          value = argument;
        });
      },
      child: Container(
        color: Colors.white,
        child: Center(
          child: Text(value),
        ),
      ),
    ));
  }
}