import 'dart:developer';
import 'package:fridgetotable/all_pages_state.dart';
import 'package:fridgetotable/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wikipedia/wikipedia.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AllController());
  runApp(
    GetMaterialApp(
      theme: ThemeData.dark(),
      home: CameraScreen(),
    ),
  );
}

getWikipediaData(response) async {
  try {
    Wikipedia instance = Wikipedia();
    final List<WikiResult> wikiResults = [];
    for (int i = 0; i < response.length; i++) {
      var result = await instance.searchQuery(
          searchQuery: response[i]["class_name"], limit: 1);
      var data = result!.query!.search!;
      var pageData = await instance.searchSummaryWithPageId(
          pageId: data[0].pageid!); //data[0].pageid
      wikiResults.add(WikiResult(
          title: pageData?.title,
          description: pageData?.description,
          extract: pageData?.extract));
    }
    return wikiResults;
  } catch (e) {
    log(e.toString());
  }
}

class WikiResult {
  String? title;
  String? description;
  String? extract;
  WikiResult({this.title, this.description, this.extract});

  factory WikiResult.empty() {
    return WikiResult(title: "", description: "", extract: "");
  }
}
