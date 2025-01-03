import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/member.dart';
import '../utils/domain.dart';

class MemberProvider with ChangeNotifier {
  List<MemberItem> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MemberItem> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //NOTE: Fetch Member Data
  Future<void> fetchMembers() async {
    _setLoadingState(true);

    try {
      final url = Uri.parse(ApiEndpoints.getMembers);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _members = _parseMemberData(response.body);
      } else {
        _setErrorState('Failed to load members: ${response.statusCode}');
      }
    } catch (error) {
      _setErrorState('Error fetching members: $error');
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

  /// Helper method to parse JSON data into MemberItems
  List<MemberItem> _parseMemberData(String responseBody) {
    final List<dynamic> data = json.decode(responseBody);
    return data.map((json) => MemberItem.fromJson(json)).toList();
  }

  /// Notify listeners after the current build cycle
  void _notifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Clear Member Data
  void clearMembers() {
    _members = [];
    _notifyListeners();
  }
}
