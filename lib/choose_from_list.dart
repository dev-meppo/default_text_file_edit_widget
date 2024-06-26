import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'singleline_edit.dart';

class ChooseFromList extends StatefulWidget {
  final File? inputFile;
  final List<String>? inputList;

  final String title;
  final String label;
  final String? hintText;
  final TextAlign textAlign;
  final TextStyle? style;
  final int? maxLines;
  final String? titleToolTip;

  /// Do you want line numbers to be shown?
  final bool showLineNumbers;

  /// If text line in [inputList] is empty its not showed.
  final bool showEmptyLines;

  final Function(int) onTapTextLine;

  const ChooseFromList({
    super.key,
    this.inputFile,
    this.inputList,
    required this.title,
    required this.label,
    this.hintText,
    required this.textAlign,
    this.maxLines,
    this.style,
    this.showLineNumbers = false,
    this.showEmptyLines = true,
    this.titleToolTip,
    required this.onTapTextLine,
  });

  @override
  ChooseFromListState createState() => ChooseFromListState();
}

class ChooseFromListState extends State<ChooseFromList> {
  late TextEditingController _textEditingController;
  int currentIndex = 0;
  late List<String> inputFileDataList;
  final bool isCircularView = true;

  @override
  void initState() {
    super.initState();
    if (widget.inputList != null) {
      inputFileDataList = widget.inputList!;
    } else {
      if (widget.inputFile != null) {
        inputFileDataList = widget.inputFile!.readAsLinesSync();
      } else {
        Exception('Both inputFile and inputList was null!');
      }
    }
    _textEditingController =
        TextEditingController(text: inputFileDataList.first);
  }

  /// Set view to next item in list relative to [currentIndex].
  void _nextItem() {
    if (currentIndex < inputFileDataList.length - 1) {
      _updateList();

      setState(() {
        currentIndex += 1;
        _textEditingController.text = inputFileDataList[currentIndex];
      });
      print("Next item! -> $currentIndex");
    } else {
      if (isCircularView) {
        setState(() {
          currentIndex = 0;
          _textEditingController.text = inputFileDataList.first;
        });
      }
      print(currentIndex);
    }
  }

  /// Set view to previous item in list relative to [currentIndex].
  void _previousItem() {
    if (currentIndex > 0) {
      _updateList();

      setState(() {
        currentIndex -= 1;
        _textEditingController.text = inputFileDataList[currentIndex];
      });
      print("Previous item! -> $currentIndex");
    } else {
      if (isCircularView) {
        setState(() {
          currentIndex = inputFileDataList.length - 1;
          _textEditingController.text = inputFileDataList.last;
        });
      }
      print(currentIndex);
    }
  }

  /// Update item in list to current text data in [_textEditingController.text].
  void _updateList() {
    if (_textEditingController.text != inputFileDataList[currentIndex]) {
      inputFileDataList[currentIndex] = _textEditingController.text;
      print("List updated!");
    }
  }

  Widget textLineCard(int index, bool showCharCount, bool isEmptyLine) {
    // Empty line.
    if (isEmptyLine) {
      return Flexible(
        child: Card(
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => widget.onTapTextLine(index),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.0,
              ),
              child: Text(
                '',
              ),
            ),
          ),
        ),
      );
    }

    return Flexible(
      child: Card(
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => widget.onTapTextLine(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
            child: Text(
              inputFileDataList[index],
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget textLineBuilder(int index, bool showEmptyLines) {
    // Show empty lines.
    if (showEmptyLines) {
      return textLineCard(index, true, inputFileDataList[index].isEmpty);

      // if (inputFileDataList[index].isNotEmpty) {
      //   return textLineCard(index, true);
      // } else {
      //   emptyLine(index);
      // }
    }

    // Dont show empty lines.
    if (!showEmptyLines) {
      if (inputFileDataList[index].isNotEmpty) {
        return textLineCard(index, true, inputFileDataList[index].isEmpty);
      } else {
        return const SizedBox.shrink(); // Return an empty widget
      }
    }

    return const SizedBox.shrink(); // Return an empty widget
  }

  /// Return line numbers.
  Widget lineNumbers(int index) {
    if (widget.showLineNumbers) {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${index + 1}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink(); // Return an empty widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: inputFileDataList.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                lineNumbers(index),
                textLineBuilder(index, widget.showEmptyLines),
              ],
            );
          },
        ),
      ),
    );
  }
}
