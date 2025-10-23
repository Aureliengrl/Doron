import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/pages/components/loader/loader_widget.dart';
import '/pages/pages/empty_chat_history/empty_chat_history_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'chat_history_widget.dart' show ChatHistoryWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatHistoryModel extends FlutterFlowModel<ChatHistoryWidget> {
  ///  Local state fields for this page.

  List<String> interests = [];
  void addToInterests(String item) => interests.add(item);
  void removeFromInterests(String item) => interests.remove(item);
  void removeAtIndexFromInterests(int index) => interests.removeAt(index);
  void insertAtIndexInInterests(int index, String item) =>
      interests.insert(index, item);
  void updateInterestsAtIndex(int index, Function(String) updateFn) =>
      interests[index] = updateFn(interests[index]);

  ContentStruct? query;
  void updateQueryStruct(Function(ContentStruct) updateFn) {
    updateFn(query ??= ContentStruct());
  }

  double? min = 0.0;

  double? max = 0.0;

  List<ProductsStruct> dummyProducts = [];
  void addToDummyProducts(ProductsStruct item) => dummyProducts.add(item);
  void removeFromDummyProducts(ProductsStruct item) =>
      dummyProducts.remove(item);
  void removeAtIndexFromDummyProducts(int index) =>
      dummyProducts.removeAt(index);
  void insertAtIndexInDummyProducts(int index, ProductsStruct item) =>
      dummyProducts.insert(index, item);
  void updateDummyProductsAtIndex(
          int index, Function(ProductsStruct) updateFn) =>
      dummyProducts[index] = updateFn(dummyProducts[index]);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
