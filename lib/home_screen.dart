

import 'package:flutter/material.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
              _getDisplays(),
              _showPresentation(),
              _hidePresentation(),
              _transferData(),
              _getDisplayeById(),
              _getDisplayByIndex(),
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
        FilledButton(
            child: Text("Get Displays"),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _indexToShareController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index to share screen',
            ),
          ),
        ),
        FilledButton(
            child: Text("Show presentation"),
            onPressed: () async {
              int? displayId = int.tryParse(_indexToShareController.text);
              if (displayId != null) {
                for (final display in displays) {
                  if (display?.displayId == displayId) {
                    displayManager.showSecondaryDisplay(
                        displayId: displayId, routerName: "presentation");
                  }
                }
              }
            }),
        const Divider(),
      ],
    );
  }

  Widget _hidePresentation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _indexToShareController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index to hide screen',
            ),
          ),
        ),
        FilledButton(
            child: Text("Hide presentation"),
            onPressed: () async {
              int? displayId = int.tryParse(_indexToShareController.text);
              if (displayId != null) {
                for (final display in displays) {
                  if (display?.displayId == displayId) {
                    displayManager.hideSecondaryDisplay(displayId: displayId);
                  }
                }
              }
            }),
        const Divider(),
      ],
    );
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
        FilledButton(
            child: Text("TransferData"),
            onPressed: () async {
              String data = _dataToTransferController.text;
              await displayManager.transferDataToPresentation(data);
            }),
        const Divider(),
      ],
    );
  }

  Widget _getDisplayeById() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _nameOfIdController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Id',
            ),
          ),
        ),
        FilledButton(
            child: Text("NameByDisplayId"),
            onPressed: () async {
              int? id = int.tryParse(_nameOfIdController.text);
              if (id != null) {
                final value = await displayManager
                    .getNameByDisplayId(displays[id]?.displayId ?? -1);
                setState(() {
                  _nameOfId = value ?? "";
                });
              }
            }),
        SizedBox(
          height: 50,
          child: Center(child: Text(_nameOfId)),
        ),
        const Divider(),
      ],
    );
  }

  Widget _getDisplayByIndex() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _nameOfIndexController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Index',
            ),
          ),
        ),
        FilledButton(
            child: Text("NameByIndex"),
            onPressed: () async {
              int? index = int.tryParse(_nameOfIndexController.text);
              if (index != null) {
                final value = await displayManager.getNameByIndex(index);
                setState(() {
                  _nameOfIndex = value ?? "";
                });
              }
            }),
        SizedBox(
          height: 50,
          child: Center(child: Text(_nameOfIndex)),
        ),
        const Divider(),
      ],
    );
  }
}