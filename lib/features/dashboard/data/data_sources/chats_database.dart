import 'dart:async';
import 'dart:developer';

import 'package:Casca/features/dashboard/data/models/chat_model.dart';
import 'package:Casca/utils/cloudinary_services.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<List<Map<String, dynamic>>> fetchChatHistoryByChatId(String chatId) async {
    try {
      final history = await collection?.find(where.eq('chatId', chatId)).toList();
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
  ) async {
    List<String> promptImages = await uploadImages(promptImage);
// api call to get response
    List<String> responseImages = await uploadImages(responseImage);
    Map<String, dynamic> chat = {
      'chatId': chatId,
      'user': user,
      'prompt': prompt,
      'promptImage': promptImages,
      'response': response,
      'responseImage': responseImages,
      'timestamp': date,
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
}
