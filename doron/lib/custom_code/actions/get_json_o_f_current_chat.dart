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

Future<String> getJsonOFCurrentChat(
    List<OpenAiResponseStruct>? openAiResponses) async {
  // Add your function code here!
  if (openAiResponses == null || openAiResponses.isEmpty) return "[]";

  List<Map<String, dynamic>> jsonList = openAiResponses
      .map((e) => {
            "followupquestion": e.followupquestion.trim() ?? "",
            "finalproductquery": e.finalproductquery.trim() ?? "",
            "usersAnswer": e.usersAnswer.trim() ?? "",
          })
      .toList();

  return jsonEncode(jsonList);
}
