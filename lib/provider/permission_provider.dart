import 'package:flutter/material.dart';
import 'package:usea_staff_test/model/permission.dart';
import '../helper/shared_pref_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/domain.dart';

class PermissionProvider with ChangeNotifier {
  List<PermissionItem> _permissions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PermissionItem> get permissions => _permissions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //NOTE: Fetch Permission Data
  Future<void> fetchPermission() async {
    _setLoadingState(true);

    try {
      final userId = await _getUserId();
      if (userId == null) return;

      final url = Uri.parse(
        '${ApiEndpoints.getPermissions}${Uri.encodeComponent(userId)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _permissions = _parsePermissionData(response.body);
      } else {
        _setErrorState('Failed to load permissions: ${response.statusCode}');
      }
    } catch (error) {
      _setErrorState('Error fetching permissions: $error');
    } finally {
      _setLoadingState(false);
    }
  }

  /// Helper method to handle loading state
  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    _notifyListeners();
  }

  /// Helper method to handle error state
  void _setErrorState(String message) {
    _errorMessage = message;
    _notifyListeners();
  }

  /// Helper method to parse JSON data into PermissionItems
  List<PermissionItem> _parsePermissionData(String responseBody) {
    final List<dynamic> data = json.decode(responseBody);
    return data.map((json) => PermissionItem.fromJson(json)).toList();
  }

  /// Get userId from SharedPreferences
  Future<String?> _getUserId() async {
    final userId = await SharedPrefHelper.getUserId();
    if (userId == null) {
      _setErrorState('User ID not found in Shared Preferences');
    }
    return userId;
  }

  /// Notify listeners after the current build cycle
  void _notifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Clear Permission Data
  void clearPermissions() {
    _permissions = [];
    _notifyListeners();
  }
}
