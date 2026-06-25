import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secondary_screen/secondary_screen.dart';

import 'order_display_screen.dart';
import 'promotion_screen.dart';
import 'sales_screen.dart';
import 'todo_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const DisplayManagerScreen());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const PromotionScreen());
    case 'todo_list':
      return MaterialPageRoute(builder: (_) => const TodoScreen());
    case 'sales':
      return MaterialPageRoute(builder: (_) => const SalesScreen());
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
    return BlocProvider(
      create: (context) => SecondaryScreenCubit(),
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        initialRoute: 'sales',
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

class DisplayManagerScreen extends StatefulWidget {
  const DisplayManagerScreen({super.key});

  @override
  State<DisplayManagerScreen> createState() => _DisplayManagerScreenState();
}

class _DisplayManagerScreenState extends State<DisplayManagerScreen> {
  late final SecondaryScreenCubit secondaryScreen = context.read<SecondaryScreenCubit>();
  DisplayManager displayManager = DisplayManager();
  List<Display?> displays = [];

  final TextEditingController _dataToTransferController = TextEditingController();
  final TextEditingController _secondaryDisplayIdController = TextEditingController();
  final List<TodoItem> _todoList = [];

  @override
  void initState() {
    context.read<SecondaryScreenCubit>().init(autoShow: true, defaultRouterName: 'presentation');
    displayManager.connectedDisplaysChangedStream?.listen(
      (event) {},
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      floatingActionButton: BlocBuilder<SecondaryScreenCubit, SecondaryScreenState>(
        builder: (context, state) {
          final isConnected = state.status == SecondaryScreenServiceState.connected;
          return FloatingActionButton(
            onPressed: isConnected
                ? () async {
                    await secondaryScreen.hideOnSecondary(clearData: true);
                  }
                : secondaryScreen.reConnectCurrentRoute,
            child: Icon(Icons.power_settings_new,
                color: isConnected ? Colors.red : Colors.green),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BlocBuilder<SecondaryScreenCubit, SecondaryScreenState>(
              builder: (context, state) {
                return Wrap(
                  children: [
                    _getDisplays(),
                    Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total displays: ${displays.length}'),
                            const SizedBox(height: 8),
                            ...displays.map((d) => Text('ID: ${d?.displayId}, Name: ${d?.name}')),
                          ],
                        ),
                      ),
                    ),
                    Card(
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
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            _connectSecondaryDisplay(),
            const Divider(),
            _transferData(),
          ],
        ),
      ),
    );
  }

  Widget _connectSecondaryDisplay() {
    return Column(
      children: [
        TextField(
          controller: _secondaryDisplayIdController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter secondary display ID',
          ),
        ),
        Button(title: "Connect Secondary Display", onPressed: () async {
          await secondaryScreen.init(autoShow: true);
        }),
      ],
    );
  }

  Widget _getDisplays() {
    return Button(
        title: "Get Displays",
        onPressed: () async {
          final values = await displayManager.getDisplays();
          displays.clear();
          setState(() {
            displays.addAll(values!);
          });
        });
  }

  Widget _transferData() {
    return Column(
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
          onPressed: _addTask,
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => ListTile(
            onTap: () => _doneTask(index),
            title: Text(_todoList[index].taskName),
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemCount: _todoList.length,
        )
      ],
    );
  }

  void _addTask() async {
    String data = _dataToTransferController.text.trim();
    if (data.isEmpty) return;

    final todo = TodoItem(id: _todoList.length + 1, taskName: data);
    _todoList.add(todo);

    final cubit = context.read<SecondaryScreenCubit>();
    final request = TransferDataModel(
      eventName: 'add_todo',
      data: todo.toJson(),
    );
    final success = await cubit.showOnSecondary(
      'todo_list',
      json: jsonEncode(request.toJson()),
    );
    if (success) {
      setState(() {});
      _dataToTransferController.clear();
    }
  }

  void _doneTask(int index) {
    final element = _todoList[index].copyWith(isCompleted: !_todoList[index].isCompleted);
    setState(() {
      _todoList
        ..removeAt(index)
        ..insert(index, element);
    });
    final cubit = context.read<SecondaryScreenCubit>();
    final request = TransferDataModel(
      eventName: 'update_todo',
      data: _todoList[index].toJson(),
    );
    cubit.showOnSecondary(
      'todo_list',
      json: jsonEncode(request.toJson()),
    );
  }
}
