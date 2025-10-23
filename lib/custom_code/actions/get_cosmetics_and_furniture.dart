// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

Future<List<bool>> getCosmeticsAndFurniture(String? apiResponse) async {
  // Add your function code here!
  if (apiResponse == null) {
    return [false, false];
  }

  try {
    final Map<String, dynamic> jsonData = jsonDecode(apiResponse);
    return [
      jsonData['is_cosmetics'] ?? false,
      jsonData['is_furniture'] ?? false
    ];
  } catch (e) {
    return [false, false]; // Agar JSON parsing fail hojaye
  }
}
