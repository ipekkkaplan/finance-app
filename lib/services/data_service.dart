import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/sector_model.dart';

class DataService {
  Future<List<SectorModel>> loadSectorData() async {
    try {

      final String response = await rootBundle.loadString('assets/sektor_analiz.json');

      final List<dynamic> data = json.decode(response);
      return data.map((json) => SectorModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("HATA: $e");
      return [];
    }
  }
}