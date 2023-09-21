import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'A really simple URL getter.'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _input = "Initial Text";
  updateText(String newText) {
    setState(() {
      _input = newText;
      // Replace with your logic
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter your string:',
              style: TextStyle(fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter your string',
                  prefixIcon: IconButton(
                    onPressed: _controller.clear,
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear',
                  ),
                  suffixIcon: PasteIconButton(
                    controller: _controller,
                    iconData: Icons.paste,
                    tooltip: 'Paste',
                  ),
                ),
                onSubmitted: (value) {
                  updateText(findSubstringIndex(_controller.text));
                },
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                updateText(findSubstringIndex(_controller.text));
                //print(findSubstringIndex(_controller.text));
              },
              tooltip: 'Get the value!',
              child: const Icon(Icons.done),
            ),
            Linkify(
              onOpen: _onOpen,
              text: "URL: $_input",
              style: const TextStyle(
                fontSize: 30,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    final Uri url = Uri.parse(link.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $link';
    }
  }
}

class PasteIconButton extends StatelessWidget {
  final TextEditingController controller;
  final IconData iconData;
  final String tooltip;

  const PasteIconButton({
    required this.controller,
    required this.iconData,
    required this.tooltip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData),
      tooltip: tooltip,
      onPressed: () async {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        if (clipboardData != null && clipboardData.text != null) {
          final currentText = controller.text;
          final cursorPosition = controller.selection.baseOffset;
          final newText = currentText.substring(0, cursorPosition) +
              clipboardData.text! +
              currentText.substring(cursorPosition);
          controller.text = newText;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: cursorPosition + clipboardData.text!.length),
          );
        }
      },
    );
  }
}

String findSubstringIndex(String text) {
  text = text.replaceAll(RegExp(r'\s+'), '');
  String substring = "http";
  int index = text.indexOf(substring);
  String slicedString = text.substring(index);
  //print(slicedString);
  if (index != -1) {
    return slicedString;
  } else {
    return "Cannot find";
  }
}
