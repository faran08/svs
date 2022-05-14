// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class TestFile extends StatefulWidget {
  const TestFile({Key? key}) : super(key: key);

  @override
  State<TestFile> createState() => _TestFileState();
}

class _TestFileState extends State<TestFile> {
  final GlobalKey genKey = GlobalKey();
  late Image newImage = Image.asset('assets/pic.jpg');

  Future<void> takePicture() async {
    RenderRepaintBoundary boundary =
        genKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    File imgFile = File('$directory/photo.png');
    setState(() {
      imgFile.writeAsBytes(pngBytes);
      newImage = Image.file(
        imgFile,
        width: 200,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: genKey,
            child: GestureDetector(
              onTap: (() {
                takePicture();
              }),
              child: Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Center(
                  child: Text('A    B    C    D'),
                ),
              ),
            ),
          ),
          newImage
        ],
      ),
    );
  }
}
