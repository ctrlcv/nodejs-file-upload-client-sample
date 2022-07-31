import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _files = "";
  String _resultText = "";
  List<File> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              GestureDetector(
                onTap: selectFile,
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: Colors.deepPurple,
                  child: const Text(
                    "File",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    _files.isNotEmpty ? _files : _resultText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: uploadFiles,
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: Colors.indigo,
                  child: const Text(
                    "Upload",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result == null) {
      return;
    }

    File file = File(result.files.single.path ?? "");
    _selectedFiles.add(file);

    _files += "\n${file.path}";

    if (mounted) {
      setState(() {});
    }
  }

  Future uploadFiles() async {
    if (_selectedFiles.isEmpty) {
      return;
    }

    String url = "http://192.168.0.39:3090/api/upload/file";
    var request = MultipartRequest('POST', Uri.parse(url));

    for (var element in _selectedFiles) {
      request.files.add(
        MultipartFile(
          'files',
          element.readAsBytes().asStream(),
          element.lengthSync(),
          filename: element.path,
        ),
      );
    }

    final streamed = await request.send();
    final response = await Response.fromStream(streamed);
    debugPrint(response.body.toString());

    // var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    // debugPrint(jsonResponse);

    _resultText = response.body.toString();
    _files = "";
    _selectedFiles = [];

    if (mounted) {
      setState(() {});
    }
  }
}
