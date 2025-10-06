import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:secondary_screen/dual_screen_service/src/transfer_data_model.dart';
import 'package:secondary_screen/promotion_screen.dart';
import 'package:secondary_screen/dual_screen_service/src/dual_screen_service.dart';
import 'package:secondary_screen/todo_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const DisplayManagerScreen());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const PromotionScreen());
    case 'todo_list':
      return MaterialPageRoute(builder: (_) => const TodoScreen());
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

  final TextEditingController _dataToTransferController = TextEditingController();
  final List<TodoItem> _todoList = [];

  @override
  void initState() {
    context.read<DualScreenCubit>().init(autoShow: true, defaultRouterName: 'presentation');
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
              labelText: 'Enter task name',
            ),
          ),
        ),
        Button(
            title: "Add task",
            onPressed: () async {
              String data = _dataToTransferController.text.trim();
              if (data.isEmpty) {
                debugPrint('❌ Task name is empty');
                return;
              }
              
              final todo = TodoItem(id: _todoList.length + 1, taskName: data);
              _todoList.add(todo);
              
              debugPrint('📝 Adding task: ${todo.toJson()}');
              debugPrint('📋 Total tasks in main: ${_todoList.length}');
              
              final cubit = context.read<DualScreenCubit>();
              final request = TransferDataModel(
                eventName: 'add_todo',
                data: todo.toJson(),
              );
              final success = await cubit.showOnSecondary(
                'todo_list',
                json: jsonEncode(request.toJson()),
              );
              if (success) {
                debugPrint('✅ Task added successfully');
                _dataToTransferController.clear();
              } else {
                debugPrint('❌ Failed to add task');
              }
            }),
        const Divider(),
      ],
    );
  }
}
