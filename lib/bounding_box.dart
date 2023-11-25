import 'package:flutter/material.dart';
import 'dart:math' as math;

class BoundingBox extends StatelessWidget {
  final List<dynamic> results;
  final int height;
  final int width;
  final double screenHeight;
  final double screenWidth;

  BoundingBox(this.results, this.height, this.width, this.screenHeight,
      this.screenWidth);

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBoxes() {
      return results.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        var scaleWidth, scaleHeight, x, y, w, h;

        if (screenHeight / screenWidth > height / width) {
          scaleWidth = screenHeight / height * width;
          scaleHeight = screenHeight;
          var difWidth = (scaleWidth - screenWidth) / scaleWidth;
          x = (_x - difWidth / 2) * scaleWidth;
          w = _w * scaleWidth;
          if (_x < difWidth / 2) w -= (difWidth / 2 - _x) * scaleWidth;
          y = _y * height;
          h = _h * height;
        } else {
          scaleHeight = screenWidth / width * height;
          scaleWidth = screenWidth;
          var difH = (scaleHeight - screenHeight) / scaleHeight;
          x = _x * scaleWidth;
          w = _w * scaleWidth;
          y = (_y - difH / 2) * scaleHeight;
          h = _h * scaleHeight;
          if (_y < difH / 2) h -= (difH / 2 - _y) * scaleHeight;
        }

        return Positioned(
          left: math.max(0, x),
          top: math.max(0, y),
          width: w,
          height: h,
          child: Container(
            padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }

    // List<Widget> _renderStrings() {
    //   double offset = -10;
    //   return results.map((re) {
    //     offset = offset + 14;
    //     return Positioned(
    //       left: 10,
    //       top: offset,
    //       width: screenWidth,
    //       height: screenHeight,
    //       child: Text(
    //         "${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
    //         style: const TextStyle(
    //           color: Color.fromRGBO(37, 213, 253, 1.0),
    //           fontSize: 14.0,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //     );
    //   }).toList();
    // }

    // List<Widget> _renderKeypoints() {
    //   var lists = <Widget>[];
    //   results.forEach((re) {
    //     var list = re["keypoints"].values.map<Widget>((k) {
    //       var _x = k["x"];
    //       var _y = k["y"];
    //       var scaleWidth, scaleHeight, x, y;

    //       if (screenHeight / screenWidth > height / width) {
    //         scaleWidth = height / height * width;
    //         scaleHeight = height;
    //         var difW = (scaleWidth - screenWidth) / scaleWidth;
    //         x = (_x - difW / 2) * scaleWidth;
    //         y = _y * scaleHeight;
    //       } else {
    //         scaleHeight = screenWidth / width * height;
    //         scaleWidth = screenWidth;
    //         var difH = (scaleHeight - screenHeight) / scaleHeight;
    //         x = _x * scaleWidth;
    //         y = (_y - difH / 2) * scaleHeight;
    //       }
    //       return Positioned(
    //         left: x - 6,
    //         top: y - 6,
    //         width: 100,
    //         height: 12,
    //         child: Container(
    //           child: Text(
    //             "● ${k["part"]}",
    //             style: const TextStyle(
    //               color: Color.fromRGBO(37, 213, 253, 1.0),
    //               fontSize: 12.0,
    //             ),
    //           ),
    //         ),
    //       );
    //     }).toList();

    //     lists.addAll(list);
    //   });

    //   return lists;
    // }

    return Stack(
      children: _renderBoxes(),
    );
  }
}
