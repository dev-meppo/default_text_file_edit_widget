import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'choose_from_list.dart';
import 'singleline_edit.dart';

class FileTextEditNormal extends StatefulWidget {
  final File inputFile;
  final String title;
  final String label;
  final String? hintText;
  final TextAlign textAlign;
  final TextStyle? style;
  final int? maxLines;
  final bool? isCircularView;
  final String? titleToolTip;

  const FileTextEditNormal({
    super.key,
    required this.inputFile,
    required this.title,
    required this.label,
    this.hintText,
    required this.textAlign,
    this.maxLines,
    this.style,
    this.isCircularView,
    this.titleToolTip,
  });

  @override
  FileTextEditNormalState createState() => FileTextEditNormalState();
}

class FileTextEditNormalState extends State<FileTextEditNormal> {
  late TextEditingController _textEditingController;
  late List<String> inputData;

  late final String filename;
  int textMode = 1;
  int currentEditMode = 1;
  double? textFontSize = 18;

  @override
  void initState() {
    super.initState();
    inputData = widget.inputFile.readAsStringSync().split('\n');
    _textEditingController = TextEditingController(text: inputData.join('\n'));

    filename = widget.inputFile.path.split('/').last;

    init();
  }

  init() async {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  /// Set view mode.
  ///
  /// 1. Normal text editing view.
  /// 2. Focused editing view.
  void setTextViewMode(int mode) {
    if (currentEditMode == 1 && mode == 2) {
      if (inputData != _textEditingController.text.split('\n')) {
        setState(() {
          inputData = _textEditingController.text.split('\n');
        });

        if (kDebugMode) {
          logDebugInfo(
            functionName: 'setTextViewMode',
            printList: [
              'Current mode 1 going to $mode.',
              'Splitted mode 1 string into mode 2 list.',
            ],
          );
        }
      } else {
        logDebugInfo(
          functionName: 'setTextViewMode',
          printList: [
            'Current mode $currentEditMode going to $mode.',
            'Data was not edited',
          ],
        );
      }
    }

    if (currentEditMode == 2 && mode == 1) {
      if (_textEditingController.text.split('\n') != inputData) {
        setState(() {
          _textEditingController.text = inputData.join('\n');
        });

        if (kDebugMode) {
          logDebugInfo(
            functionName: 'setTextViewMode',
            printList: [
              'Current mode 2 going to $mode.',
              'Joined mode 2 list into mode 1 string.',
            ],
          );
        }
      } else {
        logDebugInfo(
          functionName: 'setTextViewMode',
          printList: [
            'Current mode 2 going to $mode.',
            'Data was not edited',
          ],
        );
      }
    }

    if (mode != textMode) {
      setState(() {
        textMode = mode;
        currentEditMode = mode;
      });
    }
  }

  void saveFile() {
    print(inputData);
    if (_textEditingController.text.split('\n') == inputData) {
      print('File not modified!');
    } else {
      print('File saved: ${widget.inputFile.path}');
      widget.inputFile.writeAsStringSync(_textEditingController.text);
      inputData = _textEditingController.text.split('\n');
    }
  }

  Future<void> _singleLineEditPage(int index) async {
    TextAlign textAlign = TextAlign.start;
    double fontSize = 18;

    if (inputData[index].length < 40) {
      textAlign = TextAlign.center;
      fontSize = 22;
    }

    String editedText = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MinimalTextEdit(
          textLine: inputData[index],
          title: 'Line ${index + 1}',
          hintText: 'Type here',
          textAlign: textAlign,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );

    if (editedText != inputData[index]) {
      if (editedText.contains('\n')) {
        print('NEWLINE WAS INCLUDED');

        var textListToAdd = editedText.split('\n');

        print('Removed: ${inputData[index]}');
        print('Added: $textListToAdd');

        setState(() {
          inputData.removeAt(index);
          inputData.insertAll(index, textListToAdd);
        });
      } else {
        setState(() {
          inputData[index] = editedText;
        });
      }
    } else {
      if (kDebugMode) {
        print("ChooseFromList._singleLineEditPage()");
        print("Textline not edited");
      }
    }
  }

  Widget home({required bool isCompact, required int textMode}) {
    print('Home text mode is: $textMode');

    if (textMode == 2) {
      return Stack(
        children: [
          ChooseFromList(
            inputList: inputData,
            title: filename,
            label: '',
            textAlign: TextAlign.center,
            showEmptyLines: true,
            showLineNumbers: false,
            onTapTextLine: (index) {
              _singleLineEditPage(index);
            },
          ),
          contentTitle(isCompact),
          hoverBar()
        ],
      );
    }

    return Stack(
      children: [
        textModeNormal(isCompact: isCompact),
        contentTitle(isCompact),
        // buildBackButton(isCompact),
        hoverBar(),
      ],
    );
  }

  /// for pushing the text little bit down so
  /// its not behind top top title.
  Widget contentPadding() {
    return const SizedBox(
      height: 40,
    );
  }

  Widget contentTitle(bool isCompact) {
    double maxWidth = 800;

    if (isCompact) {
      maxWidth = 300;
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Tooltip(
        message: filename,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ElevatedButton(
                child: Text(
                  filename,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textModeRow() {
    Color? normalModeColor;
    Color? focusModeColor;

    if (textMode == 1) {
      focusModeColor = null;
      normalModeColor = Colors.green;
    } else {
      normalModeColor = null;
      focusModeColor = Colors.green;
    }

    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: normalModeColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton.icon(
                label: const Text(
                  'Normal',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  setTextViewMode(1);
                },
              ),
            ),
            Card(
              elevation: 3,
              color: focusModeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton.icon(
                onPressed: () {
                  setTextViewMode(2);
                },
                label: const Text(
                  'Focus',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget hoverBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.colorize),
                  ),
                ),
                const VerticalDivider(),
                textModeRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackButton(bool isCompact) {
    Widget button;

    if (isCompact) {
      button = const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back),
        ],
      );
    } else {
      button = const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              'Back',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () => Navigator.pop(context),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: isCompact ? 48 : 90, // Adjust width as needed
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: button,
          ),
        ),
      ),
    );
  }

  Widget textModeNormal({
    required bool isCompact,
  }) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          contentPadding(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              style: TextStyle(fontSize: textFontSize),
              decoration: const InputDecoration(
                hintText: 'Enter text here',
                border: InputBorder.none,
              ),
              maxLines: widget.maxLines,
              controller: _textEditingController,
            ),
          ),
          contentPadding(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton.filledTonal(
        tooltip: 'Save file',
        onPressed: () => saveFile(),
        icon: Icon(Icons.save),
      ),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 400) {
                    return home(isCompact: true, textMode: textMode);
                  } else {
                    return home(isCompact: false, textMode: textMode);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void logDebugInfo({
  required String functionName,
  required List<String> printList,
}) {
  print(
      '\n---$functionName()---\n${printList.join('\n')}\n---$functionName()---');
}
