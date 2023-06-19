import 'package:flutter/material.dart';
import 'package:flutter_customizable_image_cropper/crop_widget/crop_widget.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: MyComp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyComp extends StatefulWidget {
  const MyComp({super.key});

  @override
  State<MyComp> createState() => _MyCompState();
}

class _MyCompState extends State<MyComp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Library"),
      ),
      body: const Center(
        child: CustomImageCropper(
          imageType: ImageType.url,
          image: "https://picsum.photos/id/234/200/200",
        ),
      ),
    );
  }
}
