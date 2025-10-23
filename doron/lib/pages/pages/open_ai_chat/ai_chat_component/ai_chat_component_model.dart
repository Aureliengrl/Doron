import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/pages/components/loader/loader_widget.dart';
import '/pages/pages/open_ai_chat/writing_indicator/writing_indicator_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'ai_chat_component_widget.dart' show AiChatComponentWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AiChatComponentModel extends FlutterFlowModel<AiChatComponentWidget> {
  ///  Local state fields for this component.

  bool aiResponding = false;

  String inputContent = '';

  List<OpenAiResponseStruct> openAiResponse = [];
  void addToOpenAiResponse(OpenAiResponseStruct item) =>
      openAiResponse.add(item);
  void removeFromOpenAiResponse(OpenAiResponseStruct item) =>
      openAiResponse.remove(item);
  void removeAtIndexFromOpenAiResponse(int index) =>
      openAiResponse.removeAt(index);
  void insertAtIndexInOpenAiResponse(int index, OpenAiResponseStruct item) =>
      openAiResponse.insert(index, item);
  void updateOpenAiResponseAtIndex(
          int index, Function(OpenAiResponseStruct) updateFn) =>
      openAiResponse[index] = updateFn(openAiResponse[index]);

  String? query;

  List<ProductsStruct> listOfProducts = [];
  void addToListOfProducts(ProductsStruct item) => listOfProducts.add(item);
  void removeFromListOfProducts(ProductsStruct item) =>
      listOfProducts.remove(item);
  void removeAtIndexFromListOfProducts(int index) =>
      listOfProducts.removeAt(index);
  void insertAtIndexInListOfProducts(int index, ProductsStruct item) =>
      listOfProducts.insert(index, item);
  void updateListOfProductsAtIndex(
          int index, Function(ProductsStruct) updateFn) =>
      listOfProducts[index] = updateFn(listOfProducts[index]);

  int counter = 0;

  dynamic jsonData;

  int loopCounter = 0;

  bool isCosmetics = false;

  bool isFurniture = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (Send Full Prompt )] action in ai_chat_Component widget.
  ApiCallResponse? intializedGptResponse;
  // Stores action output result for [Custom Action - getOpenAiResponse] action in ai_chat_Component widget.
  OpenAiResponseStruct? aiResponse;
  // State field(s) for ListView widget.
  ScrollController? listViewController;
  // Model for writing_indicator component.
  late WritingIndicatorModel writingIndicatorModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (Send Full Prompt )] action in TextField widget.
  ApiCallResponse? chatGPTResponse;
  // Stores action output result for [Custom Action - getOpenAiResponse] action in TextField widget.
  OpenAiResponseStruct? openAiResponseOnSubmit;
  // Stores action output result for [Custom Action - getCosmeticsAndFurniture] action in TextField widget.
  List<bool>? typesOfSearrch;
  // Stores action output result for [Backend Call - API (Amazon Api for OpenAI)] action in TextField widget.
  ApiCallResponse? products;
  // Stores action output result for [Custom Action - combineListAndAddPlatForm] action in TextField widget.
  List<ProductsStruct>? combineListOnSubmit;
  // Stores action output result for [Backend Call - API (Sephora)] action in TextField widget.
  ApiCallResponse? seporaOnChange;
  // Stores action output result for [Backend Call - API (Ikea)] action in TextField widget.
  ApiCallResponse? ikeaOnChange;
  // Stores action output result for [Backend Call - API (Title Generator)] action in TextField widget.
  ApiCallResponse? titleGeneratoronSubmit;
  // Stores action output result for [Backend Call - Create Document] action in TextField widget.
  GiftSuggestionChatRecord? docCreated;
  // Stores action output result for [Backend Call - Create Document] action in TextField widget.
  GiftSuggestionChatRecord? docCreated2;
  // Stores action output result for [Backend Call - API (Send Full Prompt )] action in Container widget.
  ApiCallResponse? onTapchatGPTResponse;
  // Stores action output result for [Custom Action - getOpenAiResponse] action in Container widget.
  OpenAiResponseStruct? getResponseCopy;
  // Stores action output result for [Custom Action - getCosmeticsAndFurniture] action in Container widget.
  List<bool>? typesOfSearrchOnTap;
  // Stores action output result for [Backend Call - API (Amazon Api for OpenAI)] action in Container widget.
  ApiCallResponse? productsCopy;
  // Stores action output result for [Custom Action - combineListAndAddPlatForm] action in Container widget.
  List<ProductsStruct>? combineListCopy;
  // Stores action output result for [Backend Call - API (Sephora)] action in Container widget.
  ApiCallResponse? seporaOnSubmit;
  // Stores action output result for [Backend Call - API (Ikea)] action in Container widget.
  ApiCallResponse? ikeaOnSubmit;
  // Stores action output result for [Backend Call - API (Title Generator)] action in Container widget.
  ApiCallResponse? titleGeneratorOnTap;
  // Stores action output result for [Backend Call - Create Document] action in Container widget.
  GiftSuggestionChatRecord? dasd;
  // Stores action output result for [Backend Call - Create Document] action in Container widget.
  GiftSuggestionChatRecord? docCreate;

  @override
  void initState(BuildContext context) {
    listViewController = ScrollController();
    writingIndicatorModel = createModel(context, () => WritingIndicatorModel());
  }

  @override
  void dispose() {
    listViewController?.dispose();
    writingIndicatorModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
