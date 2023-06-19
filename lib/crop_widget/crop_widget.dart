import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'my_clipper.dart';
import 'my_painter.dart';
import 'dart:ui' as ui;
import 'dart:io';

enum ImageType { url, file, asset }

class CustomImageCropper extends StatefulWidget {
  final ImageType imageType;
  final dynamic image;
  const CustomImageCropper({
    required this.imageType,
    required this.image,
    super.key,
  });

  @override
  State<CustomImageCropper> createState() => _CustomImageCropperState();
}

class _CustomImageCropperState extends State<CustomImageCropper> {
  final image = "https://picsum.photos/id/234/200/200";
  final globalKey = GlobalKey();

  bool isCroped = false;
  bool isLoading = false;
  File cropedImageFile = File('');

  // Top Left
  double tlX = 0;
  double tlY = 0;
  // Top Right
  double trX = 100;
  double trY = 0;
  // Bottom Left
  double blX = 0;
  double blY = 100;
  // Bottom Right
  double brX = 100;
  double brY = 100;

  double pointSize = 20;
  Color pointColor = const Color(0xFFA0A1A0);
  Color lineColor = Colors.black;

  changeCropState() {
    setState(() {
      isCroped = !isCroped;
    });
  }

  changeLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future saveImage() async {
    // Get the boundary object for the RenderRepaintBoundary
    RenderRepaintBoundary? boundaryObject =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundaryObject == null) return;

    // Capture the image from the boundary object
    ui.Image image = await boundaryObject.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    // Convert the byte data to Uint8List
    Uint8List bytes = byteData.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();

    cropedImageFile = File('${directory.path}/image.png');
    await cropedImageFile.writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isCroped
                    ? Center(
                        child: Image.file(cropedImageFile),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                            opacity: 0.32,
                          ),
                        ),
                        child: CustomPaint(
                          foregroundPainter: MyCstmPainter(
                            lineColor: lineColor,
                            lineWidth: 3,
                            linePoints: [
                              // Top Left - Top Right
                              [
                                Offset(tlX + (pointSize / 2),
                                    tlY + (pointSize / 2)),
                                Offset(trX + (pointSize / 2),
                                    trY + (pointSize / 2)),
                              ],
                              // Top Right - Bottom Right
                              [
                                Offset(trX + (pointSize / 2),
                                    trY + (pointSize / 2)),
                                Offset(brX + (pointSize / 2),
                                    brY + (pointSize / 2)),
                              ],
                              // Bottom Right - Bottom Left
                              [
                                Offset(brX + (pointSize / 2),
                                    brY + (pointSize / 2)),
                                Offset(blX + (pointSize / 2),
                                    blY + (pointSize / 2)),
                              ],
                              // Bottom Left - Top Left
                              [
                                Offset(blX + (pointSize / 2),
                                    blY + (pointSize / 2)),
                                Offset(tlX + (pointSize / 2),
                                    tlY + (pointSize / 2)),
                              ],
                            ],
                          ),
                          child: Stack(
                            children: [
                              RepaintBoundary(
                                key: globalKey,
                                child: ClipPath(
                                  clipper: MyImageClipper(
                                    points: [
                                      Offset(tlX + (pointSize / 2),
                                          tlY + (pointSize / 2)),
                                      Offset(trX + (pointSize / 2),
                                          trY + (pointSize / 2)),
                                      Offset(brX + (pointSize / 2),
                                          brY + (pointSize / 2)),
                                      Offset(blX + (pointSize / 2),
                                          blY + (pointSize / 2)),
                                    ],
                                  ),
                                  child: Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              pointTL(),
                              pointTR(),
                              pointBL(),
                              pointBR(),
                            ],
                          ),
                        ),
                      ),
                ElevatedButton(
                  onPressed: () async {
                    changeLoading();
                    await saveImage();
                    changeCropState();
                    changeLoading();
                  },
                  child: const Text("Save Image"),
                )
              ],
            ),
          );
  }

  Widget pointTL() {
    return Positioned(
      top: tlY,
      left: tlX,
      child: Draggable(
        feedback: customPointer(),
        child: customPointer(),
        onDragUpdate: (details) {
          setState(() {
            tlY = tlY + details.delta.dy;
            tlX = tlX + details.delta.dx;
          });
        },
      ),
    );
  }

  Widget pointTR() {
    return Positioned(
      top: trY,
      left: trX,
      child: Draggable(
        feedback: customPointer(),
        child: customPointer(),
        onDragUpdate: (details) {
          setState(() {
            trY = trY + details.delta.dy;
            trX = trX + details.delta.dx;
          });
        },
      ),
    );
  }

  Widget pointBL() {
    return Positioned(
      top: blY,
      left: blX,
      child: Draggable(
        feedback: customPointer(),
        child: customPointer(),
        onDragUpdate: (details) {
          setState(() {
            blY = blY + details.delta.dy;
            blX = blX + details.delta.dx;
          });
        },
      ),
    );
  }

  Widget pointBR() {
    return Positioned(
      top: brY,
      left: brX,
      child: Draggable(
        feedback: customPointer(),
        child: customPointer(),
        onDragUpdate: (details) {
          setState(() {
            brY = brY + details.delta.dy;
            brX = brX + details.delta.dx;
          });
        },
      ),
    );
  }

  Widget customPointer() {
    return Container(
      width: pointSize,
      height: pointSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: pointColor, width: 1.5),
      ),
    );
  }
}
