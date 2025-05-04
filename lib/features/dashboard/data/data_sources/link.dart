import 'dart:async';
import 'dart:developer';

import 'package:Casca/features/dashboard/data/models/chat_model.dart';
import 'package:Casca/utils/cloudinary_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mongo_dart/mongo_dart.dart';

final connectionURL =
    "mongodb+srv://casca:casca@casca.gctq7.mongodb.net/CascaDB?retryWrites=true&w=majority";

class TempLink {
  static Db? db;
  static DbCollection? collection;

  TempLink();

  static Future<void> connect() async {
    db = await Db.create(connectionURL);
    await db?.open();
    inspect(db);
    collection = db?.collection('temp');
  }

  static Future<String?> getLink() async {
    try {
      final link = await collection?.findOne();
      return link?['link'];
    } catch (e) {
      return null;
    }
  }

  static Future<void> close() async {
    await db?.close();
    log('Connection to MongoDB closed');
  }
}
