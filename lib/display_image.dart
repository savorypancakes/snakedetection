import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fridgetotable/display_image_controller.dart';
import 'package:get/get.dart';

class DisplayImage extends StatelessWidget {
  final controller = Get.put(DisplayImageController());
  DisplayImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        body: SingleChildScrollView(
            child: Obx(
          () => controller.isPredicting.value
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.memory(
                      controller.predictedImage.value,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(height: 10),
                    Obx(() => PredictionsDisplay(
                          predictions: controller.predictions,
                        )),
                    const SizedBox(height: 10),
                    WikiResultsDisplay(),
                  ],
                ),
        )));
  }
}

class PredictionsDisplay extends StatelessWidget {
  final List<Prediction> predictions;
  const PredictionsDisplay({super.key, required this.predictions});

  @override
  Widget build(BuildContext context) {
    final List<Widget> results = [];
    for (int i = 0; i < predictions.length; i++) {
      results.add(Text(
        "Name of Species: ${predictions[i].className}",
        style: const TextStyle(fontSize: 20),
      ));
      results.add(const SizedBox(height: 10));
      results.add(Text(
        "Confidence: ${predictions[i].confidence}",
        style: const TextStyle(fontSize: 20),
      ));
    }
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: results,
        ),
      ),
    );
  }
}

class WikiResultsDisplay extends StatelessWidget {
  final controller = Get.find<DisplayImageController>();
  WikiResultsDisplay({super.key});
  final List<Widget> results = [];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      for (int i = 0; i < controller.wikiResults.length; i++) {
        results.add(Column(
          children: [
            Obx(() => Text(
                  controller.wikiResults[i].title ?? "",
                  style: const TextStyle(fontSize: 20),
                )),
            Obx(() => Text(
                  controller.wikiResults[i].description ?? "",
                  style: const TextStyle(fontSize: 20),
                )),
            Obx(() => Text(
                  controller.wikiResults[i].snippet ?? "",
                  style: const TextStyle(fontSize: 20),
                )),
          ],
        ));
      }
      return Column(children: results);
    });
  }
}
