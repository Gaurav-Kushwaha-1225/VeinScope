import 'dart:async';
import 'dart:math';

import 'package:Casca/features/dashboard/data/data_sources/barber_database.dart';

import '../../domain/repository/barber_repository.dart';

class BarberRepositoryImpl implements BarberRepository {
  final CascaBarberDB cascaDB;
  BarberRepositoryImpl(this.cascaDB);

  @override
  Future<List<Map<String, dynamic>>> fetchChatHistory(String email) {
    return cascaDB.fetchChatHistory(email);
  }
}
