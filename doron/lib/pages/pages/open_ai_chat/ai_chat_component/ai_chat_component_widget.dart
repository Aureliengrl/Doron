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
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ai_chat_component_model.dart';
export 'ai_chat_component_model.dart';

class AiChatComponentWidget extends StatefulWidget {
  const AiChatComponentWidget({super.key});

  @override
  State<AiChatComponentWidget> createState() => _AiChatComponentWidgetState();
}

class _AiChatComponentWidgetState extends State<AiChatComponentWidget> {
  late AiChatComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AiChatComponentModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.addToOpenAiResponse(OpenAiResponseStruct(
        followupquestion: FFLocalizations.of(context).languageCode == 'en'
            ? ((String var1) {
                return 'Hello $var1';
              }(currentUserDisplayName))
            : ((String var1) {
                return 'Bonjour $var1';
              }(currentUserDisplayName)),
      ));
      _model.aiResponding = true;
      safeSetState(() {});
      _model.jsonData = _model.openAiResponse.firstOrNull?.toMap();
      // The "chatHistory" is the generated JSON -- we send the whole chat history to AI in order for it to understand context.
      _model.intializedGptResponse =
          await OpenAIChatGPTOrignalGroup.sendFullPromptCall.call(
        apiKey: FFDevEnvironmentValues().openAiApiKey,
        query:
            'this is the first prompt, generate a personalized question for product search',
        language: FFLocalizations.of(context).languageCode,
      );

      if ((_model.intializedGptResponse?.succeeded ?? true)) {
        _model.aiResponse = await actions.getOpenAiResponse(
          OpenAIChatGPTOrignalGroup.sendFullPromptCall.content(
            (_model.intializedGptResponse?.jsonBody ?? ''),
          )!,
          '',
        );
        _model.jsonData = functions.saveChatHistory(
            _model.jsonData, _model.aiResponse!.toMap());
        _model.aiResponding = false;
        _model.addToOpenAiResponse(_model.aiResponse!);
        safeSetState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your API Call Failed!',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.interTight(
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).info,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).titleSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleSmall.fontStyle,
                  ),
            ),
            duration: Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
        _model.aiResponding = false;
        safeSetState(() {});
      }

      await Future.delayed(
        Duration(
          milliseconds: 800,
        ),
      );
      await _model.listViewController?.animateTo(
        _model.listViewController!.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.ease,
      );
      _model.aiResponding = false;
      safeSetState(() {});
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 770.0,
        ),
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional(0.0, -1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (responsiveVisibility(
                      context: context,
                      phone: false,
                      tablet: false,
                    ))
                      Container(
                        width: 100.0,
                        height: 24.0,
                        decoration: BoxDecoration(),
                      ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 12.0, 12.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5.0,
                              sigmaY: 4.0,
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).accent4,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional(0.0, -1.0),
                                      child: Builder(
                                        builder: (context) {
                                          final chat = _model.openAiResponse
                                              .map((e) => e)
                                              .toList();
                                          if (chat.isEmpty) {
                                            return Container(
                                              width: double.infinity,
                                              child: LoaderWidget(),
                                            );
                                          }

                                          return ListView.separated(
                                            padding: EdgeInsets.fromLTRB(
                                              0,
                                              16.0,
                                              0,
                                              16.0,
                                            ),
                                            scrollDirection: Axis.vertical,
                                            itemCount: chat.length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 12.0),
                                            itemBuilder: (context, chatIndex) {
                                              final chatItem = chat[chatIndex];
                                              return Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 0.0, 12.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if ((chatItem.usersAnswer !=
                                                            '') ||
                                                        (chatItem.usersAnswer !=
                                                                null &&
                                                            chatItem.usersAnswer !=
                                                                ''))
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Flexible(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .starsColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          12.0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          0.0),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          12.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          12.0),
                                                                ),
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .alternate,
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        chatItem
                                                                            .usersAnswer,
                                                                        'UserQA',
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.inter(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (chatItem
                                                            .followupquestion !=
                                                        '')
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Flexible(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .starsColor,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              0.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              12.0),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              12.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              12.0),
                                                                    ),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      width:
                                                                          2.0,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            8.0,
                                                                            12.0,
                                                                            8.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        SelectionArea(
                                                                            child:
                                                                                AutoSizeText(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            (String
                                                                                var1) {
                                                                              return var1.replaceAll('product', 'gift');
                                                                            }(chatItem.followupquestion),
                                                                            'AiAnswer',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.inter(
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                lineHeight: 1.5,
                                                                              ),
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ].divide(
                                                      SizedBox(height: 12.0)),
                                                ),
                                              );
                                            },
                                            controller:
                                                _model.listViewController,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(),
                                    child: Visibility(
                                      visible: _model.aiResponding,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          wrapWithModel(
                                            model: _model.writingIndicatorModel,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: WritingIndicatorWidget(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          12.0, 12.0, 12.0, 12.0),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          onFieldSubmitted: (_) async {
                            if ((_model.textController.text != null &&
                                    _model.textController.text != '') &&
                                !_model.aiResponding &&
                                (_model.counter < 8)) {
                              // addToChat_aiTyping
                              _model.aiResponding = true;
                              _model.query = _model.textController.text;
                              _model.addToOpenAiResponse(OpenAiResponseStruct(
                                usersAnswer: _model.textController.text,
                              ));
                              _model.counter = _model.counter + 1;
                              safeSetState(() {});
                              safeSetState(() {
                                _model.textController?.clear();
                              });
                              // The "chatHistory" is the generated JSON -- we send the whole chat history to AI in order for it to understand context.
                              _model.chatGPTResponse =
                                  await OpenAIChatGPTOrignalGroup
                                      .sendFullPromptCall
                                      .call(
                                apiKey: FFDevEnvironmentValues().openAiApiKey,
                                query: _model.query,
                                language:
                                    FFLocalizations.of(context).languageCode,
                                prompt: _model.jsonData?.toString(),
                              );

                              if ((_model.chatGPTResponse?.succeeded ?? true)) {
                                _model.openAiResponseOnSubmit =
                                    await actions.getOpenAiResponse(
                                  OpenAIChatGPTOrignalGroup.sendFullPromptCall
                                      .content(
                                    (_model.chatGPTResponse?.jsonBody ?? ''),
                                  )!,
                                  _model.inputContent,
                                );
                                _model.typesOfSearrch =
                                    await actions.getCosmeticsAndFurniture(
                                  OpenAIChatGPTOrignalGroup.sendFullPromptCall
                                      .content(
                                    (_model.chatGPTResponse?.jsonBody ?? ''),
                                  ),
                                );
                                _model.jsonData = functions.saveChatHistory(
                                    _model.jsonData,
                                    _model.openAiResponseOnSubmit!.toMap());
                                _model.isCosmetics =
                                    _model.typesOfSearrch!.firstOrNull!;
                                _model.isFurniture =
                                    _model.typesOfSearrch!.lastOrNull!;
                                _model.updateOpenAiResponseAtIndex(
                                  _model.openAiResponse.length - 1,
                                  (e) => e
                                    ..followupquestion = _model.counter < 7
                                        ? _model.openAiResponseOnSubmit
                                            ?.followupquestion
                                        : ''
                                    ..finalproductquery = _model
                                        .openAiResponseOnSubmit
                                        ?.finalproductquery,
                                );
                                if (_model.counter > 2) {
                                  _model.loopCounter = 0;
                                  _model.products =
                                      await AmazonApiForOpenAICall.call(
                                    query: _model.openAiResponseOnSubmit
                                        ?.finalproductquery,
                                    country: FFLocalizations.of(context)
                                                .languageCode ==
                                            'en'
                                        ? 'us'
                                        : 'fr',
                                  );

                                  if ((_model.products?.succeeded ?? true)) {
                                    _model.combineListOnSubmit =
                                        await actions.combineListAndAddPlatForm(
                                      _model.listOfProducts.toList(),
                                      AmazonApiForOpenAICall.productsList(
                                        (_model.products?.jsonBody ?? ''),
                                      )?.toList(),
                                      Platforms.amazon,
                                    );
                                    _model.listOfProducts = _model
                                        .combineListOnSubmit!
                                        .unique((e) => e)
                                        .toList()
                                        .cast<ProductsStruct>();
                                  }
                                  if (_model.getResponseCopy
                                              ?.finalproductquery !=
                                          null &&
                                      _model.getResponseCopy
                                              ?.finalproductquery !=
                                          '') {
                                    if (_model.isCosmetics) {
                                      _model.seporaOnChange =
                                          await SephoraCall.call(
                                        search: _model.openAiResponseOnSubmit
                                            ?.finalproductquery,
                                      );

                                      if ((_model.seporaOnChange?.succeeded ??
                                          true)) {
                                        while (SephoraCall.productLink(
                                              (_model.seporaOnChange
                                                      ?.jsonBody ??
                                                  ''),
                                            )!
                                                .length >
                                            _model.loopCounter) {
                                          _model.addToListOfProducts(
                                              ProductsStruct(
                                            productTitle:
                                                SephoraCall.description(
                                              (_model.seporaOnChange
                                                      ?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                    _model.loopCounter),
                                            productPrice: SephoraCall.price(
                                              (_model.seporaOnChange
                                                      ?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                _model.loopCounter),
                                            productUrl: SephoraCall.productLink(
                                              (_model.seporaOnChange
                                                      ?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                _model.loopCounter),
                                            productOriginalPrice:
                                                SephoraCall.price(
                                              (_model.seporaOnChange
                                                      ?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                    _model.loopCounter),
                                            productStarRating:
                                                SephoraCall.rating(
                                              (_model.seporaOnChange
                                                      ?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                    _model.loopCounter),
                                            productPhoto: SephoraCall.imgLink(
                                              (_model.seporaOnChange
                                                      ?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                _model.loopCounter),
                                            productNumRatings: (String? var1) {
                                              return int.parse(var1 ?? '0');
                                            }((SephoraCall.rating(
                                              (_model.seporaOnChange
                                                      ?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                _model.loopCounter))),
                                            platform: Platforms.sephora,
                                          ));
                                          _model.loopCounter =
                                              _model.loopCounter + 1;
                                        }
                                      }
                                    }
                                    _model.loopCounter = 0;
                                    safeSetState(() {});
                                    if (_model.isFurniture) {
                                      _model.ikeaOnChange = await IkeaCall.call(
                                        keyword: _model.openAiResponseOnSubmit
                                            ?.finalproductquery,
                                        countryCode: FFLocalizations.of(context)
                                                    .languageCode ==
                                                'en'
                                            ? 'us'
                                            : 'fr',
                                        languageCode:
                                            FFLocalizations.of(context)
                                                .languageCode,
                                      );

                                      if ((_model.ikeaOnChange?.succeeded ??
                                          true)) {
                                        while (IkeaCall.producttitle(
                                              (_model.ikeaOnChange?.jsonBody ??
                                                  ''),
                                            )!
                                                .length >
                                            _model.loopCounter) {
                                          _model.addToListOfProducts(
                                              ProductsStruct(
                                            productTitle: IkeaCall.producttitle(
                                              (_model.ikeaOnChange?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                _model.loopCounter),
                                            productPrice: '${(IkeaCall.currency(
                                                  (_model.ikeaOnChange
                                                          ?.jsonBody ??
                                                      ''),
                                                )?.elementAtOrNull(_model.loopCounter)) == 'USD' ? '\$' : '€'}${(IkeaCall.productprice(
                                              (_model.ikeaOnChange?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(_model.loopCounter))?.toString()}',
                                            productUrl: IkeaCall.producturl(
                                              (_model.ikeaOnChange?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                _model.loopCounter),
                                            productPhoto: IkeaCall.productphoto(
                                              (_model.ikeaOnChange?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(
                                                _model.loopCounter),
                                            platform: Platforms.ikea,
                                          ));
                                          _model.loopCounter =
                                              _model.loopCounter + 1;
                                        }
                                      }
                                    }
                                    _model.loopCounter = 0;
                                    safeSetState(() {});
                                  }
                                  _model.listOfProducts = _model.listOfProducts
                                      .unique((e) => e)
                                      .toList()
                                      .cast<ProductsStruct>();
                                  _model.loopCounter = 0;
                                }
                                _model.counter = _model.counter + 1;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Your API Call Failed!',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .info,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                                _model.aiResponding = false;
                                safeSetState(() {});
                              }

                              if (_model.counter > 6) {
                                _model.listOfProducts = functions
                                    .productsShuffling(
                                        _model.listOfProducts.toList())!
                                    .toList()
                                    .cast<ProductsStruct>();
                                if ((_model.listOfProducts.isNotEmpty) ==
                                    true) {
                                  _model.titleGeneratoronSubmit =
                                      await OpenAIChatGPTOrignalGroup
                                          .titleGeneratorCall
                                          .call(
                                    prompt: _model.jsonData?.toString(),
                                    apiKey:
                                        FFDevEnvironmentValues().openAiApiKey,
                                  );

                                  if ((_model
                                          .titleGeneratoronSubmit?.succeeded ??
                                      true)) {
                                    var giftSuggestionChatRecordReference1 =
                                        GiftSuggestionChatRecord.collection
                                            .doc();
                                    await giftSuggestionChatRecordReference1
                                        .set({
                                      ...createGiftSuggestionChatRecordData(
                                        title: functions.getTitle(
                                            OpenAIChatGPTOrignalGroup
                                                .titleGeneratorCall
                                                .title(
                                          (_model.titleGeneratoronSubmit
                                                  ?.jsonBody ??
                                              ''),
                                        )),
                                        userId: currentUserReference,
                                        timestamp: getCurrentTimestamp,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'Products':
                                              getProductsListFirestoreData(
                                            _model.listOfProducts,
                                          ),
                                          'OpenAiResponses':
                                              getOpenAiResponseListFirestoreData(
                                            _model.openAiResponse,
                                          ),
                                        },
                                      ),
                                    });
                                    _model.docCreated = GiftSuggestionChatRecord
                                        .getDocumentFromData({
                                      ...createGiftSuggestionChatRecordData(
                                        title: functions.getTitle(
                                            OpenAIChatGPTOrignalGroup
                                                .titleGeneratorCall
                                                .title(
                                          (_model.titleGeneratoronSubmit
                                                  ?.jsonBody ??
                                              ''),
                                        )),
                                        userId: currentUserReference,
                                        timestamp: getCurrentTimestamp,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'Products':
                                              getProductsListFirestoreData(
                                            _model.listOfProducts,
                                          ),
                                          'OpenAiResponses':
                                              getOpenAiResponseListFirestoreData(
                                            _model.openAiResponse,
                                          ),
                                        },
                                      ),
                                    }, giftSuggestionChatRecordReference1);
                                  } else {
                                    var giftSuggestionChatRecordReference2 =
                                        GiftSuggestionChatRecord.collection
                                            .doc();
                                    await giftSuggestionChatRecordReference2
                                        .set({
                                      ...createGiftSuggestionChatRecordData(
                                        title: FFLocalizations.of(context)
                                                    .languageCode ==
                                                'en'
                                            ? 'No Title Suggested'
                                            : 'Aucun titre suggéré',
                                        userId: currentUserReference,
                                        timestamp: getCurrentTimestamp,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'Products':
                                              getProductsListFirestoreData(
                                            _model.listOfProducts,
                                          ),
                                          'OpenAiResponses':
                                              getOpenAiResponseListFirestoreData(
                                            _model.openAiResponse,
                                          ),
                                        },
                                      ),
                                    });
                                    _model.docCreated2 =
                                        GiftSuggestionChatRecord
                                            .getDocumentFromData({
                                      ...createGiftSuggestionChatRecordData(
                                        title: FFLocalizations.of(context)
                                                    .languageCode ==
                                                'en'
                                            ? 'No Title Suggested'
                                            : 'Aucun titre suggéré',
                                        userId: currentUserReference,
                                        timestamp: getCurrentTimestamp,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'Products':
                                              getProductsListFirestoreData(
                                            _model.listOfProducts,
                                          ),
                                          'OpenAiResponses':
                                              getOpenAiResponseListFirestoreData(
                                            _model.openAiResponse,
                                          ),
                                        },
                                      ),
                                    }, giftSuggestionChatRecordReference2);
                                  }

                                  if (Navigator.of(context).canPop()) {
                                    context.pop();
                                  }
                                  context.pushNamed(
                                    OpenAiSuggestedGiftsWidget.routeName,
                                    queryParameters: {
                                      'fetchproducts': serializeParam(
                                        _model.listOfProducts,
                                        ParamType.DataStruct,
                                        isList: true,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        FFLocalizations.of(context)
                                                    .languageCode ==
                                                'en'
                                            ? 'Oops! Gift selection didn’t work, try again.'
                                            : 'Oups ! La sélection du cadeau n\'a pas fonctionné, réessayez.',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                  context.safePop();
                                }
                              } else {
                                await _model.listViewController?.animateTo(
                                  _model.listViewController!.position
                                      .maxScrollExtent,
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.ease,
                                );
                              }

                              _model.aiResponding = false;
                              safeSetState(() {});
                            }

                            safeSetState(() {});
                          },
                          autofocus: false,
                          textCapitalization: TextCapitalization.sentences,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: FFLocalizations.of(context).getText(
                              'l4uezc6t' /* Tapez quelque chose... */,
                            ),
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .fontStyle,
                                ),
                            errorStyle:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).error,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                    ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).accent4,
                            contentPadding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 24.0, 70.0, 24.0),
                            suffixIcon: Icon(
                              Icons.send,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 18.0,
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                  ),
                          minLines: 1,
                          cursorColor: FlutterFlowTheme.of(context).primary,
                          validator: _model.textControllerValidator
                              .asValidator(context),
                          inputFormatters: [
                            if (!isAndroid && !isiOS)
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                return TextEditingValue(
                                  selection: newValue.selection,
                                  text: newValue.text.toCapitalization(
                                      TextCapitalization.sentences),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: Align(
                      alignment: AlignmentDirectional(1.0, 1.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 22.0, 20.0, 0.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            // if ai is nt responding and textfield isnt null and counter is greater than 6
                            if ((_model.textController.text != null &&
                                    _model.textController.text != '') &&
                                !_model.aiResponding &&
                                (_model.counter < 8)) {
                              // addToChat_aiTyping
                              _model.aiResponding = true;
                              _model.query = _model.textController.text;
                              _model.addToOpenAiResponse(OpenAiResponseStruct(
                                usersAnswer: _model.textController.text,
                              ));
                              _model.counter = _model.counter + 1;
                              safeSetState(() {});
                              safeSetState(() {
                                _model.textController?.clear();
                              });
                              // The "chatHistory" is the generated JSON -- we send the whole chat history to AI in order for it to understand context.
                              _model.onTapchatGPTResponse =
                                  await OpenAIChatGPTOrignalGroup
                                      .sendFullPromptCall
                                      .call(
                                apiKey: FFDevEnvironmentValues().openAiApiKey,
                                prompt: _model.jsonData?.toString(),
                                query: _model.query,
                                language:
                                    FFLocalizations.of(context).languageCode,
                              );

                              if ((_model.onTapchatGPTResponse?.succeeded ??
                                  true)) {
                                _model.getResponseCopy =
                                    await actions.getOpenAiResponse(
                                  OpenAIChatGPTOrignalGroup.sendFullPromptCall
                                      .content(
                                    (_model.onTapchatGPTResponse?.jsonBody ??
                                        ''),
                                  )!,
                                  _model.query,
                                );
                                _model.typesOfSearrchOnTap =
                                    await actions.getCosmeticsAndFurniture(
                                  OpenAIChatGPTOrignalGroup.sendFullPromptCall
                                      .content(
                                    (_model.onTapchatGPTResponse?.jsonBody ??
                                        ''),
                                  ),
                                );
                                _model.jsonData = functions.saveChatHistory(
                                    _model.jsonData,
                                    _model.getResponseCopy!.toMap());
                                _model.isCosmetics =
                                    _model.typesOfSearrchOnTap!.firstOrNull!;
                                _model.isFurniture =
                                    _model.typesOfSearrchOnTap!.lastOrNull!;
                                _model.updateOpenAiResponseAtIndex(
                                  _model.openAiResponse.length - 1,
                                  (e) => e
                                    ..followupquestion = _model.counter < 7
                                        ? _model
                                            .getResponseCopy?.followupquestion
                                        : ''
                                    ..finalproductquery = _model
                                        .getResponseCopy?.finalproductquery,
                                );
                                if (_model.counter > 2) {
                                  _model.loopCounter = 0;
                                  _model.productsCopy =
                                      await AmazonApiForOpenAICall.call(
                                    query: _model
                                        .getResponseCopy?.finalproductquery,
                                    country: FFLocalizations.of(context)
                                                .languageCode ==
                                            'en'
                                        ? 'us'
                                        : 'fr',
                                  );

                                  if ((_model.productsCopy?.succeeded ??
                                      true)) {
                                    _model.combineListCopy =
                                        await actions.combineListAndAddPlatForm(
                                      _model.listOfProducts.toList(),
                                      AmazonApiForOpenAICall.productsList(
                                        (_model.productsCopy?.jsonBody ?? ''),
                                      )?.toList(),
                                      Platforms.amazon,
                                    );
                                    _model.listOfProducts = _model
                                        .combineListCopy!
                                        .unique((e) => e)
                                        .toList()
                                        .cast<ProductsStruct>();
                                  }
                                  if (_model.isCosmetics) {
                                    _model.seporaOnSubmit =
                                        await SephoraCall.call(
                                      search: _model.getResponseCopy
                                                      ?.finalproductquery !=
                                                  null &&
                                              _model.getResponseCopy
                                                      ?.finalproductquery !=
                                                  ''
                                          ? _model.getResponseCopy
                                              ?.finalproductquery
                                          : 'best',
                                    );

                                    if ((_model.seporaOnSubmit?.succeeded ??
                                        true)) {
                                      while (SephoraCall.totalReviews(
                                            (_model.seporaOnSubmit?.jsonBody ??
                                                ''),
                                          )!
                                              .length >
                                          _model.loopCounter) {
                                        _model
                                            .addToListOfProducts(ProductsStruct(
                                          productTitle: SephoraCall.description(
                                            (_model.seporaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter),
                                          productPrice: SephoraCall.price(
                                            (_model.seporaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter),
                                          productUrl: SephoraCall.productLink(
                                            (_model.seporaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter),
                                          productOriginalPrice:
                                              SephoraCall.price(
                                            (_model.seporaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                                  _model.loopCounter),
                                          productStarRating: SephoraCall.rating(
                                            (_model.seporaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter),
                                          productPhoto: SephoraCall.imgLink(
                                            (_model.seporaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter),
                                          productNumRatings: (String? var1) {
                                            return int.parse(var1 ?? '0');
                                          }((SephoraCall.totalReviews(
                                            (_model.seporaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter))),
                                          platform: Platforms.sephora,
                                        ));
                                        _model.loopCounter =
                                            _model.loopCounter + 1;
                                      }
                                    }
                                  }
                                  _model.loopCounter = 0;
                                  if (_model.isFurniture) {
                                    _model.ikeaOnSubmit = await IkeaCall.call(
                                      keyword: _model
                                          .getResponseCopy?.finalproductquery,
                                      countryCode: FFLocalizations.of(context)
                                                  .languageCode ==
                                              'en'
                                          ? 'us'
                                          : 'fr',
                                      languageCode: FFLocalizations.of(context)
                                          .languageCode,
                                    );

                                    if ((_model.ikeaOnSubmit?.succeeded ??
                                        true)) {
                                      while (IkeaCall.producttitle(
                                            (_model.ikeaOnSubmit?.jsonBody ??
                                                ''),
                                          )!
                                              .length >
                                          _model.loopCounter) {
                                        _model
                                            .addToListOfProducts(ProductsStruct(
                                          productTitle: IkeaCall.producttitle(
                                            (_model.ikeaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter),
                                          productPrice: '${(IkeaCall.currency(
                                                            (_model.ikeaOnSubmit
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )?.elementAtOrNull(_model.loopCounter)) == 'USD' ? '\$' : '€'}${(IkeaCall.productprice(
                                                        (_model.ikeaOnSubmit
                                                                ?.jsonBody ??
                                                            ''),
                                                      )?.elementAtOrNull(_model.loopCounter))?.toString()}' !=
                                                      null &&
                                                  '${(IkeaCall.currency(
                                                            (_model.ikeaOnSubmit
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )?.elementAtOrNull(_model.loopCounter)) == 'USD' ? '\$' : '€'}${(IkeaCall.productprice(
                                                        (_model.ikeaOnSubmit
                                                                ?.jsonBody ??
                                                            ''),
                                                      )?.elementAtOrNull(_model.loopCounter))?.toString()}' !=
                                                      ''
                                              ? '${(IkeaCall.currency(
                                                    (_model.ikeaOnSubmit
                                                            ?.jsonBody ??
                                                        ''),
                                                  )?.elementAtOrNull(_model.loopCounter)) == 'USD' ? '\$' : '€'}${(IkeaCall.productprice(
                                                  (_model.ikeaOnSubmit
                                                          ?.jsonBody ??
                                                      ''),
                                                )?.elementAtOrNull(_model.loopCounter))?.toString()}'
                                              : 'N/A',
                                          productUrl: IkeaCall.producturl(
                                            (_model.ikeaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter),
                                          productPhoto: IkeaCall.productphoto(
                                            (_model.ikeaOnSubmit?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(
                                              _model.loopCounter),
                                          platform: Platforms.ikea,
                                        ));
                                        _model.loopCounter =
                                            _model.loopCounter + 1;
                                      }
                                    }
                                  }
                                  _model.listOfProducts = _model.listOfProducts
                                      .unique((e) => e)
                                      .toList()
                                      .cast<ProductsStruct>();
                                  _model.counter = _model.counter + 1;
                                  _model.loopCounter = 0;
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Your API Call Failed!',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .info,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                                _model.aiResponding = false;
                                safeSetState(() {});
                              }

                              if (_model.counter > 6) {
                                _model.listOfProducts = functions
                                    .productsShuffling(
                                        _model.listOfProducts.toList())!
                                    .toList()
                                    .cast<ProductsStruct>();
                                if ((_model.listOfProducts.isNotEmpty) ==
                                    true) {
                                  _model.titleGeneratorOnTap =
                                      await OpenAIChatGPTOrignalGroup
                                          .titleGeneratorCall
                                          .call(
                                    apiKey:
                                        FFDevEnvironmentValues().openAiApiKey,
                                    prompt: _model.jsonData?.toString(),
                                  );

                                  if ((_model.titleGeneratorOnTap?.succeeded ??
                                      true)) {
                                    var giftSuggestionChatRecordReference1 =
                                        GiftSuggestionChatRecord.collection
                                            .doc();
                                    await giftSuggestionChatRecordReference1
                                        .set({
                                      ...createGiftSuggestionChatRecordData(
                                        title: valueOrDefault<String>(
                                          functions.getTitle(
                                              OpenAIChatGPTOrignalGroup
                                                  .titleGeneratorCall
                                                  .title(
                                            (_model.titleGeneratorOnTap
                                                    ?.jsonBody ??
                                                ''),
                                          )),
                                          'No title found',
                                        ),
                                        userId: currentUserReference,
                                        timestamp: getCurrentTimestamp,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'Products':
                                              getProductsListFirestoreData(
                                            _model.listOfProducts,
                                          ),
                                          'OpenAiResponses':
                                              getOpenAiResponseListFirestoreData(
                                            _model.openAiResponse,
                                          ),
                                        },
                                      ),
                                    });
                                    _model.dasd = GiftSuggestionChatRecord
                                        .getDocumentFromData({
                                      ...createGiftSuggestionChatRecordData(
                                        title: valueOrDefault<String>(
                                          functions.getTitle(
                                              OpenAIChatGPTOrignalGroup
                                                  .titleGeneratorCall
                                                  .title(
                                            (_model.titleGeneratorOnTap
                                                    ?.jsonBody ??
                                                ''),
                                          )),
                                          'No title found',
                                        ),
                                        userId: currentUserReference,
                                        timestamp: getCurrentTimestamp,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'Products':
                                              getProductsListFirestoreData(
                                            _model.listOfProducts,
                                          ),
                                          'OpenAiResponses':
                                              getOpenAiResponseListFirestoreData(
                                            _model.openAiResponse,
                                          ),
                                        },
                                      ),
                                    }, giftSuggestionChatRecordReference1);
                                  } else {
                                    var giftSuggestionChatRecordReference2 =
                                        GiftSuggestionChatRecord.collection
                                            .doc();
                                    await giftSuggestionChatRecordReference2
                                        .set({
                                      ...createGiftSuggestionChatRecordData(
                                        title: FFLocalizations.of(context)
                                                    .languageCode ==
                                                'en'
                                            ? 'No Title Suggested'
                                            : 'Aucun titre suggéré',
                                        userId: currentUserReference,
                                        timestamp: getCurrentTimestamp,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'Products':
                                              getProductsListFirestoreData(
                                            _model.listOfProducts,
                                          ),
                                          'OpenAiResponses':
                                              getOpenAiResponseListFirestoreData(
                                            _model.openAiResponse,
                                          ),
                                        },
                                      ),
                                    });
                                    _model.docCreate = GiftSuggestionChatRecord
                                        .getDocumentFromData({
                                      ...createGiftSuggestionChatRecordData(
                                        title: FFLocalizations.of(context)
                                                    .languageCode ==
                                                'en'
                                            ? 'No Title Suggested'
                                            : 'Aucun titre suggéré',
                                        userId: currentUserReference,
                                        timestamp: getCurrentTimestamp,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'Products':
                                              getProductsListFirestoreData(
                                            _model.listOfProducts,
                                          ),
                                          'OpenAiResponses':
                                              getOpenAiResponseListFirestoreData(
                                            _model.openAiResponse,
                                          ),
                                        },
                                      ),
                                    }, giftSuggestionChatRecordReference2);
                                  }

                                  if (Navigator.of(context).canPop()) {
                                    context.pop();
                                  }
                                  context.pushNamed(
                                    OpenAiSuggestedGiftsWidget.routeName,
                                    queryParameters: {
                                      'fetchproducts': serializeParam(
                                        _model.listOfProducts,
                                        ParamType.DataStruct,
                                        isList: true,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        FFLocalizations.of(context)
                                                    .languageCode ==
                                                'en'
                                            ? 'Oops! Gift selection didn’t work, try again.'
                                            : 'Oups ! La sélection du cadeau n\'a pas fonctionné, réessayez.',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                  context.safePop();
                                }
                              } else {
                                await _model.listViewController?.animateTo(
                                  _model.listViewController!.position
                                      .maxScrollExtent,
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.ease,
                                );
                              }

                              _model.aiResponding = false;
                              safeSetState(() {});
                            }

                            safeSetState(() {});
                          },
                          child: Container(
                            width: 80.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (responsiveVisibility(
              context: context,
              phone: false,
              tablet: false,
            ))
              Container(
                width: 100.0,
                height: 60.0,
                decoration: BoxDecoration(),
              ),
          ],
        ),
      ),
    );
  }
}
