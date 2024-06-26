import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'file_text_edit_normal.dart';

File? INPUT_FILE;

void main(List<String> args) {
  if (args.isNotEmpty) {
    if (File(args.first).existsSync()) {
      INPUT_FILE = File(args.first);
    } else {
      print('File was provided as input argument, but does not exist');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  MyAppState({Key? key});
  File? file;

  @override
  void initState() {
    super.initState();

    if (INPUT_FILE != null) {
      file = INPUT_FILE;
    } else {
      init();
    }
  }

  Future<void> init() async {
    await pickFile();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile pickedFile = result.files.first;
      if (pickedFile.path != null) {
        print(pickedFile.path);
        setState(() {
          file = File(pickedFile.path!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.grey),
          displayMedium: TextStyle(color: Colors.grey),
          displaySmall: TextStyle(color: Colors.grey),
          headlineLarge: TextStyle(color: Colors.grey),
          headlineMedium: TextStyle(color: Colors.grey),
          headlineSmall: TextStyle(color: Colors.grey),
          titleLarge: TextStyle(color: Colors.grey),
          titleMedium: TextStyle(color: Colors.grey),
          titleSmall: TextStyle(color: Colors.grey),
          bodyLarge: TextStyle(color: Colors.grey),
          bodyMedium: TextStyle(color: Colors.grey),
          bodySmall: TextStyle(color: Colors.grey),
          labelLarge: TextStyle(color: Colors.grey),
          labelMedium: TextStyle(color: Colors.grey),
          labelSmall: TextStyle(color: Colors.grey),
        ),
        /* dark theme settings */
      ),
      themeMode: ThemeMode.system,
      home: SafeArea(
        child: Scaffold(
          body: Builder(
            builder: (context) => FileTextEditNormal(
              inputFile: file!,
              title: 'Test File',
              hintText: '',
              label: 'Block',
              textAlign: TextAlign.start,
              maxLines: null,
            ),
          ),
        ),
      ),
    );
  }
}
