import 'package:flutter/material.dart';

class MinimalTextEdit extends StatefulWidget {
  final String textLine;
  final String title;
  final String? hintText;
  final TextAlign textAlign;
  final TextStyle? style;
  final Widget? textBoxTop;
  final int? maxLines;

  const MinimalTextEdit({
    super.key,
    required this.textLine,
    required this.textAlign,
    this.title = "",
    this.hintText,
    this.textBoxTop,
    this.maxLines,
    this.style,
  });

  @override
  MinimalTextEditState createState() => MinimalTextEditState();
}

class MinimalTextEditState extends State<MinimalTextEdit> {
  late TextEditingController _textEditingController;

  late int charCount;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.textLine);

    charCount = widget.textLine.length;
  }

  void updateCharCount() {
    print('updateCharCount');
    setState(() {
      charCount = _textEditingController.text.length;
    });
  }

  Widget stringInfo() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('c: '),
              Text(charCount.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget textInputField() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextField(
          onChanged: (value) => updateCharCount(),
          style: widget.style,
          textAlign: widget.textAlign,
          controller: _textEditingController,
          decoration: InputDecoration(
            labelStyle: const TextStyle(fontSize: 20),
            label: widget.textBoxTop,
            hintText: widget.hintText,
            border: InputBorder.none,
          ),
          maxLines: widget.maxLines,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 1200,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textInputField(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        String editedText = _textEditingController.text;
                        // Handle the edited text as needed

                        Navigator.pop(context, editedText);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Done',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        stringInfo(),
      ]),
    );
  }
}
