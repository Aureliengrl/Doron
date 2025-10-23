import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/pages/open_ai_chat/ai_preview_component/ai_preview_component_widget.dart';
import 'preview_chat_widget.dart' show PreviewChatWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PreviewChatModel extends FlutterFlowModel<PreviewChatWidget> {
  ///  Local state fields for this page.

  String? inputContent = '';

  dynamic chatHistory;

  bool aiResponding = false;

  ///  State fields for stateful widgets in this page.

  // Model for ai_preview_component component.
  late AiPreviewComponentModel aiPreviewComponentModel;

  @override
  void initState(BuildContext context) {
    aiPreviewComponentModel =
        createModel(context, () => AiPreviewComponentModel());
  }

  @override
  void dispose() {
    aiPreviewComponentModel.dispose();
  }
}
