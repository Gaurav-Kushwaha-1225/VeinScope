import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

Future<List<String>> uploadImages(FilePickerResult? images) async {
  if (images == null || images.files.isEmpty) {
    return [];
  }

  String cloudName = "dbda07xha";
  List<String> imageUrls = [];

  try {
    File imageFile = File(images.files[0].path!);
    var uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");

    var request = http.MultipartRequest("POST", uri);
    request.fields["upload_preset"] = "veinscope";
    request.fields["resource_type"] = "raw"; // Change from "raw" to "image"

    var multipartFile =
        await http.MultipartFile.fromPath("file", imageFile.path);
    request.files.add(multipartFile);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    // log(responseBody);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      String imageUrl = jsonResponse["secure_url"];
      imageUrls.add(imageUrl);
      // log("Image uploaded successfully: $imageUrl");
    } else {
      // log("Image upload failed: ${response.statusCode}");
    }
  } catch (e) {
    log("Error uploading image: $e");
  }

  return imageUrls;
}
