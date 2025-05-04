import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:Casca/features/dashboard/data/data_sources/link.dart';
import 'package:Casca/features/dashboard/data/models/chat_model.dart';
import 'package:Casca/utils/cloudinary_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';

final connectionURL =
    "mongodb+srv://casca:casca@casca.gctq7.mongodb.net/CascaDB?retryWrites=true&w=majority";

class CascaVeinScopeDB {
  static Db? db;
  static DbCollection? collection;

  CascaVeinScopeDB();

  static Future<void> connect() async {
    db = await Db.create(connectionURL);
    await db?.open();
    inspect(db);
    collection = db?.collection('History');
  }

  Future<List<Map<String, dynamic>>> fetchChatHistory(String email) async {
    try {
      final history = await collection?.find(where.eq('user', email)).toList();
      return history ?? [];
    } catch (e) {
      log(e as String);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchChatHistoryByChatId(
      String chatId) async {
    try {
      final history =
          await collection?.find(where.eq('chatId', chatId)).toList();
      return history ?? [];
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<ChatModel?> addChatToHistory(
    String chatId,
    String user,
    String prompt,
    FilePickerResult promptImage,
    String response,
    FilePickerResult responseImage,
    String date,
    List<List<int>>? promptVector,
  ) async {
    List<String> promptImages = await uploadImages(promptImage);
    String? link = await TempLink.getLink();
    String responseImages = '';
    if (promptImages.isNotEmpty && link != null) {
      Map<String, dynamic> data = await _postRequestWithImageAndVector(
          link, promptImages[0], promptVector);
      responseImages = data['image_link'] ?? "";
      response = data['features'] ?? "";
    }

    // List<String> responseImages = await uploadImages(responseImage);
    Map<String, dynamic> chat = {
      'chatId': chatId,
      'user': user,
      'prompt': prompt,
      'promptImage': promptImages,
      'response': response, // TODO: generate from gpt
      'responseImage': [responseImages, ],
      'timestamp': date,
      'promptVector': promptVector,
    };
    try {
      await collection?.insert(chat);
      return ChatModel.fromMap(chat);
    } catch (e) {
      log(e as String);
      return null;
    }
  }

  static Future<void> close() async {
    await db?.close();
    log('Connection to MongoDB closed');
  }

  Future<Map<String, dynamic>> _postRequestWithImageAndVector(
      String link, String promptImage, List<List<int>>? promptVector) async {
    try {
      final url = Uri.parse(link);
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'image_url': promptImage,
        'prompt_vector': promptVector ?? [[]],
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data ?? {};
      } else {
        throw Exception('Failed to get response: ${response.body}');
      }
    } catch (e) {
      print('Error in _postRequestWithImageAndVector: $e');
      throw Exception('Error in making POST request');
    }
  }
}
