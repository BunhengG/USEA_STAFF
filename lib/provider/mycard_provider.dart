import 'package:flutter/material.dart';
import '../helper/shared_pref_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/user.dart';
import '../utils/domain.dart';

class CardProvider with ChangeNotifier {
  List<UserItem> _cards = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserItem> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //NOTE: Fetch Card Data
  Future<void> fetchCards() async {
    _setLoadingState(true);

    try {
      final userId = await _getUserId();
      if (userId == null) return;

      final url = Uri.parse(
        '${ApiEndpoints.getUsersByID}${Uri.encodeComponent(userId)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _cards = _parseCardData(response.body);
      } else {
        _setErrorState('Failed to load cards: ${response.statusCode}');
      }
    } catch (error) {
      _setErrorState('Error fetching cards: $error');
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

  /// Helper method to parse JSON data into CardItems
  List<UserItem> _parseCardData(String responseBody) {
    final List<dynamic> data = json.decode(responseBody);
    return data.map((json) => UserItem.fromJson(json)).toList();
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

  /// Clear Card Data
  void clearCards() {
    _cards = [];
    _notifyListeners();
  }
}
