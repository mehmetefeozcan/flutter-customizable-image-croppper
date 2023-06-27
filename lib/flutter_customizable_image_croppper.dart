// ignore_for_file: unnecessary_null_in_if_null_operators

library flutter_customizable_image_croppper;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'src/my_clipper.dart';
import 'src/my_painter.dart';

enum ImageType { url, file, asset }

class CustomizableImageCropper extends StatefulWidget {
  final ImageType imageType;
  final dynamic image;
  final double? width;
  final double? height;
  final ButtonStyle? buttonStyle;
  final String? buttonTitle;

  const CustomizableImageCropper({
    required this.imageType,
    required this.image,
    this.buttonStyle,
    this.buttonTitle,
    this.height,
    this.width,
    super.key,
  });

  @override
  State<CustomizableImageCropper> createState() =>
      _CustomizableImageCropperState();
}

class _CustomizableImageCropperState extends State<CustomizableImageCropper> {
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

  getImageWidget(int formIndex) {
    if (formIndex == 0) {
      if (widget.imageType == ImageType.file) {
        return FileImage(widget.image);
      } else if (widget.imageType == ImageType.url) {
        return NetworkImage(widget.image);
      } else if (widget.imageType == ImageType.asset) {
        return AssetImage(widget.image);
      }
    } else {
      if (widget.imageType == ImageType.file) {
        return Image.file(
          widget.image,
          fit: BoxFit.cover,
          width: widget.width ?? 280,
          height: widget.height ?? 280,
        );
      } else if (widget.imageType == ImageType.url) {
        return Image.network(
          widget.image,
          fit: BoxFit.cover,
          width: widget.width ?? 280,
          height: widget.height ?? 280,
        );
      } else if (widget.imageType == ImageType.asset) {
        return Image.asset(
          widget.image,
          fit: BoxFit.cover,
          width: widget.width ?? 280,
          height: widget.height ?? 280,
        );
      }
    }
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
                        child: Image.file(
                          cropedImageFile,
                          width: widget.width ?? 280,
                          height: widget.height ?? 280,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: getImageWidget(0),
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
                                Offset(
                                  tlX + (pointSize / 2),
                                  tlY + (pointSize / 2),
                                ),
                                Offset(
                                  trX + (pointSize / 2),
                                  trY + (pointSize / 2),
                                ),
                              ],
                              // Top Right - Bottom Right
                              [
                                Offset(
                                  trX + (pointSize / 2),
                                  trY + (pointSize / 2),
                                ),
                                Offset(
                                  brX + (pointSize / 2),
                                  brY + (pointSize / 2),
                                ),
                              ],
                              // Bottom Right - Bottom Left
                              [
                                Offset(
                                  brX + (pointSize / 2),
                                  brY + (pointSize / 2),
                                ),
                                Offset(
                                  blX + (pointSize / 2),
                                  blY + (pointSize / 2),
                                ),
                              ],
                              // Bottom Left - Top Left
                              [
                                Offset(
                                  blX + (pointSize / 2),
                                  blY + (pointSize / 2),
                                ),
                                Offset(
                                  tlX + (pointSize / 2),
                                  tlY + (pointSize / 2),
                                ),
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
                                      Offset(
                                        tlX + (pointSize / 2),
                                        tlY + (pointSize / 2),
                                      ),
                                      Offset(
                                        trX + (pointSize / 2),
                                        trY + (pointSize / 2),
                                      ),
                                      Offset(
                                        brX + (pointSize / 2),
                                        brY + (pointSize / 2),
                                      ),
                                      Offset(
                                        blX + (pointSize / 2),
                                        blY + (pointSize / 2),
                                      ),
                                    ],
                                  ),
                                  child: getImageWidget(1),
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
                  style: widget.buttonStyle ?? null,
                  onPressed: () async {
                    changeLoading();
                    await saveImage();
                    changeCropState();
                    changeLoading();
                  },
                  child: Text(widget.buttonTitle ?? "Save Image"),
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
            if (details.globalPosition.dx >
                    MediaQuery.of(context).size.width * 0.08 &&
                details.globalPosition.dx <
                    MediaQuery.of(context).size.width * 0.915) {
              tlX = tlX + details.delta.dx;
            }

            tlY = tlY + details.delta.dy;
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
            if (details.globalPosition.dx >
                    MediaQuery.of(context).size.width * 0.08 &&
                details.globalPosition.dx <
                    MediaQuery.of(context).size.width * 0.915) {
              trX = trX + details.delta.dx;
            }
            trY = trY + details.delta.dy;
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
            if (details.globalPosition.dx >
                    MediaQuery.of(context).size.width * 0.08 &&
                details.globalPosition.dx <
                    MediaQuery.of(context).size.width * 0.915) {
              blX = blX + details.delta.dx;
            }
            blY = blY + details.delta.dy;
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
            if (details.globalPosition.dx >
                    MediaQuery.of(context).size.width * 0.08 &&
                details.globalPosition.dx <
                    MediaQuery.of(context).size.width * 0.915) {
              brX = brX + details.delta.dx;
            }
            brY = brY + details.delta.dy;
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
