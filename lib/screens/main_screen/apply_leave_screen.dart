import 'dart:convert';

import 'package:app_5/encrypt_decrypt.dart';
import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/providers/connectivity_helper.dart';
import 'package:app_5/repository/app_repository.dart';
import 'package:app_5/screens/sub_screen/leave_history.dart';
import 'package:app_5/service/api_service.dart';
import 'package:app_5/widgets/common_widgets/button.dart';
import 'package:app_5/widgets/common_widgets/snackbar_message.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:app_5/widgets/common_widgets/text_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  AppRepository leaveRepository = AppRepository(ApiService(baseUrl: 'https://maduraimarket.in/api'));
  final formKey = GlobalKey<FormState>();
  final SharedPreferences prefs = SharedpreferenceHelper.getInstance;
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController commentsController = TextEditingController();
  bool isApplying = false;
  @override
  void dispose() {
    super.dispose();
    startDateController.dispose();
    endDateController.dispose();
    commentsController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Apply Leave"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          style: const ButtonStyle(
            overlayColor: WidgetStatePropertyAll(Colors.black12)
          ),
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent.withValues(alpha: 0.0),
        titleTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black
        ),
        actions: [
          // Leave History 
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, size.width * 0.05, 0),
            child: Consumer2<ApiProvider, ConnectivityService>(
              builder: (context, provider, connection, child) {
                return GestureDetector(
                  onTap: () async {
                    await provider.leavesListAPI(context).then((value) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const LeaveHistoryScreen(),
                      ));
                    },);
                  },
                  child: const Tooltip(
                    message: 'History',
                    child: Icon(Icons.history_rounded),
                  ),
                );
              }
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextWidget(text: 'Start date', fontWeight: FontWeight.w500, fontSize: 16),
                const SizedBox(height: 15,),
                // Start Date Field
                TextFields(
                  isObseure: false, 
                  controller: startDateController,
                  textInputAction: TextInputAction.next,
                  // hintText: 'Enter Start Time',
                  readOnly: true,
                  hintText: 'Start Time',
                  onTap: () async {
                    DateTime? startTime = await showDatePicker(
                      context: context, 
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now()
                    );
                    setState(() {
                      if (startTime != null) {
                        startDateController.text = DateFormat("yyyy-MM-dd").format(startTime);
                      }else{
                        startDateController.text = "";
                      }
                    });
                    print(startDateController.text);
                  },
                  validator: (value) {
                    if (value == "" && value!.isEmpty) {
                      return "Start Date is Required";
                    }else{
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20,),
                const TextWidget(text: 'End date', fontWeight: FontWeight.w500, fontSize: 16),
                const SizedBox(height: 15,),
                // End Date Field
                TextFields(
                  isObseure: false, 
                  controller: endDateController,
                  textInputAction: TextInputAction.next,
                  // hintText: 'Enter Start Time',
                  readOnly: true,
                  hintText: 'End date',
                  onTap: () async {
                    if (startDateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarMessage(
                          context: context, 
                          message: "Select Start date first", 
                          backgroundColor: Theme.of(context).primaryColor,
                          bottomPadding: size.height * 0.05,
                          sidePadding: size.width * 0.1
                        )
                      );
                    }else{
                      DateTime? endDate = await showDatePicker(
                        context: context, 
                        firstDate: DateFormat("yyyy-MM-dd").parse(startDateController.text),
                        lastDate: DateTime(2100),
                        initialDate: DateFormat("yyyy-MM-dd").parse(startDateController.text),
                      );
                      setState(() {
                        if (endDate != null) {
                          endDateController.text = DateFormat("yyyy-MM-dd").format(endDate);
                        }else{
                          endDateController.text = "";
                        }
                      });
                      print('End Date: ${endDateController.text}');
                    }
                  },
                  validator: (value) {
                    if (value == "" && value!.isEmpty) {
                      return "End Date is Required";
                    }else{
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20,),
                const TextWidget(text: 'Comments', fontWeight: FontWeight.w500, fontSize: 16),
                const SizedBox(height: 15,),
                TextFields(
                  isObseure: false, 
                  controller: commentsController,
                  textInputAction: TextInputAction.done,
                  maxLines: 4,
                  hintText: 'Comments',
                  validator: (value) {
                    if (value == "" && value!.isEmpty) {
                      return "Comments is Required";
                    }else{
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20,),
                Center(
                  child: Consumer2<ApiProvider, ConnectivityService>(
                      builder: (context, provider, connection, child) {
                      return isApplying
                        ? const LoadingButton(width: double.infinity,)
                        : ButtonWidget(
                          width: double.infinity,
                          title: "Apply", 
                          onPressed: () async {
                            setState(() {
                              isApplying = true;
                            });
                            try {
                              if (connection.isConnected) {
                                if (formKey.currentState!.validate()) {
                                  Map<String, dynamic> applyLeaveData = {
                                    "delivery_executive_id": prefs.getString("executiveId"),
                                    "start_date": startDateController.text,
                                    "end_date": endDateController.text,
                                    "comments": commentsController.text
                                  };
                                      
                                  final response = await leaveRepository.applyLeave(applyLeaveData);
                                  final decryptedResponse = decryptAES(response.body).replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), "");
                                  final decodedResponse = json.decode(decryptedResponse);
                                  print('Apply Leave Response: $decodedResponse, Status Code: ${response.statusCode}');
                                  final applyLeaveMessage = snackBarMessage(
                                    context: context, 
                                    message: decodedResponse['message'], 
                                    backgroundColor: const Color(0xFF60B47B), 
                                    sidePadding: size.width * 0.1, 
                                    bottomPadding: size.height * 0.05
                                  );
                                  if (response.statusCode == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(applyLeaveMessage).closed.then((value) async {
                                      startDateController.clear();
                                      endDateController.clear();
                                      commentsController.clear();
                                      provider.leavesListAPI(context);
                                    },);
                                  }else{
                                    print('Error: $decodedResponse');
                                  }
                                }
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                    context: context, 
                                  message: "No internet!", 
                                  backgroundColor: const Color(0xFF60B47B), 
                                  sidePadding: size.width * 0.1, 
                                  bottomPadding: size.height * 0.05
                                ));
                              }
                            } catch (e) {
                              print("Can't apply leave: $e");
                            }  finally {
                              setState(() {
                                isApplying = false;
                              });
                              
                            }
                          },
                        );
                      
                    }
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
