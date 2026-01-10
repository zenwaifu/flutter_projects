import 'package:flutter/material.dart';
import '../models/inspection.dart';
import '../services/db_service.dart';

class InspectionProvider extends ChangeNotifier {
  List<Inspection> _inspections = [];
  bool _isLoading = false;

  List<Inspection> get inspections => _inspections;
  bool get isLoading => _isLoading;

  final DBService _dbService = DBService();

  // Load all inspections from database
  Future<void> loadInspections() async {
    _isLoading = true;
    notifyListeners();

    try {
      _inspections = await _dbService.getAllInspections();
    } catch (e) {
      print('Error loading inspections: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new inspection
  Future<void> addInspection(Inspection inspection) async {
    try {
      await _dbService.insertInspection(inspection);
      await loadInspections(); // Reload list
    } catch (e) {
      print('Error adding inspection: $e');
    }
  }

  // Update existing inspection
  Future<void> updateInspection(Inspection inspection) async {
    try {
      await _dbService.updateInspection(inspection);
      await loadInspections(); // Reload list
    } catch (e) {
      print('Error updating inspection: $e');
    }
  }

  // Delete inspection
  Future<void> deleteInspection(int id) async {
    try {
      await _dbService.deleteInspection(id);
      await loadInspections(); // Reload list
    } catch (e) {
      print('Error deleting inspection: $e');
    }
  }
}