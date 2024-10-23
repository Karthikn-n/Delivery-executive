import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/widgets/common_widgets/text_field_widget.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../widgets/common_widgets/button.dart';

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Applied Leaves"),
          // automaticallyImplyLeading: false,
          leading: IconButton(
            style: const ButtonStyle(
              overlayColor: WidgetStatePropertyAll(Colors.black12)
            ),
            icon: const Icon(CupertinoIcons.chevron_back),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent.withOpacity(0.0),
          titleTextStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black
          ),
        ),
        body: Consumer<ApiProvider>(
          builder: (context, provider, child) {
            return provider.leavesList.isEmpty
            ? FutureBuilder(
              future: provider.leavesListAPI(context), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }else if(snapshot.hasError){
                  return const Center(
                    child: TextWidget(text: "No Leaves", fontWeight: FontWeight.w500, fontSize: 15),
                  );
                } else {
                  return leaveList(context, size);
                }
              },
            )
            : leaveList(context, size);
          }
        ),
      ),
    );
  }

  Widget leaveList(BuildContext context, Size size){
    return Consumer<ApiProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: ListView.builder(
            itemCount: provider.leavesList.length,
            itemBuilder: (context, index) {
              // int differnece = DateTime.parse( provider.leavesList[index].endDate).difference(DateTime.parse(provider.leavesList[index].startDate)).inDays;
              String startDate = DateFormat("dd MMM yyyy").format(DateTime.parse(provider.leavesList[index].startDate));
              String endDate = DateFormat("dd MMM yyyy").format(DateTime.parse(provider.leavesList[index].endDate));
              // int difference = DateFormat("dd MMM yyyy").parse(endDate).difference(DateFormat("dd MMM yyyy").parse(startDate)).inDays;
              return Column(
                children: [
                  Container(
                    width: size.width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.shade300
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // comment 
                             SizedBox(
                              width: size.width*0.65,
                              child: TextWidget(
                                text: provider.leavesList[index].comments,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis, 
                                fontWeight: FontWeight.w600, 
                                fontSize: 16,
                                fontColor: Colors.teal,
                              ),
                            ),
                            // Icons
                            Row(
                              children: [
                                // Edit Icon
                                GestureDetector(
                                  onTap: () async {
                                    provider.updateEditLeave(null, true);
                                    provider.updateEditLeave(null, false);
                                    print("Leave ID: ${provider.leavesList[index].leaveId}");
                                    editLeaveSheet(
                                      DateFormat("yyyy-MM-dd").parse(provider.leavesList[index].startDate), 
                                      DateFormat("yyyy-MM-dd").parse(provider.leavesList[index].endDate), 
                                      provider.leavesList[index].comments, 
                                      context, size, index
                                    );
                                  }, 
                                  child: const Icon(CupertinoIcons.pencil)
                                ),
                                const SizedBox(width: 8,),
                                GestureDetector(
                                  onTap: () async {
                                    provider.confirmDeleteLeave(context, size, provider.leavesList[index].leaveId, index);
                                  }, 
                                  child: const Icon(
                                    CupertinoIcons.delete_simple,
                                    size: 20,
                                    color: Colors.red ,
                                  )
                                ),
                                const SizedBox(width: 5,)
                              ],
                            )
                          ],
                        ),
                        TextWidget(
                          text:  "$startDate - $endDate", 
                          fontWeight: FontWeight.w600, 
                          fontSize: 24
                        ),
                        // Status
                        TextWidget(
                              text: provider.leavesList[index].status == null 
                                ? 'Pending'
                                : provider.leavesList[index].status!, 
                              fontWeight: FontWeight.w500, 
                              fontSize: 16,
                              fontColor:provider.leavesList[index].status == null 
                              ?  Colors.red
                              : Colors.grey,
                            ),
                       
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,)
                ],
              );
            },
          ),
        );
      },
    );
  }


  // Edit leave bottom sheet
  void editLeaveSheet(
    DateTime? startDate,
    DateTime? endDate,
    String comment,
    BuildContext screenContext,
    Size size,
    int index, 
  ){
    showModalBottomSheet(
      context: screenContext, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer<ApiProvider>(
          builder: (context, provider, child) {
            return StatefulBuilder(
              builder: (context, sheetState) {
                final TextEditingController commentsController = TextEditingController(text: comment);
                return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
                        const Center(
                          child: Column(
                            children: [
                              TextWidget(text: "Update", fontWeight: FontWeight.w500, fontSize: 18),
                              SizedBox(
                                width: 40,
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Edit start date 
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextWidget(text: "Start date", fontSize: 14, fontWeight: FontWeight.w500),
                                  const SizedBox(height: 10,),
                                  ElevatedButton(
                                    iconAlignment: IconAlignment.end,
                                    onPressed: () async {
                                      DateTime? editStartDate = await showDatePicker(
                                        context: context, 
                                        firstDate: startDate!, 
                                        lastDate: endDate!,
                                        initialDate: startDate,
                                        fieldLabelText: "Start Date",
                                        helpText: "Start Date",
                                      );
                                      if (editStartDate != null) {
                                        provider.updateEditLeave(editStartDate, true);
                                      }else{
                                        provider.updateEditLeave(null, true);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      backgroundColor: Colors.transparent.withOpacity(0.0),
                                      shadowColor: Colors.transparent.withOpacity(0.0),
                                      overlayColor: Colors.transparent.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color:  Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8)
                                      )
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(
                                          text: provider.updatedStartTime != null
                                          ? DateFormat("dd MMM yyyy").format(provider.updatedStartTime!)
                                          : DateFormat("dd MMM yyyy").format(startDate!), 
                                          fontSize: 12, 
                                          fontColor: Colors.black,
                                          fontWeight: FontWeight.w400
                                        ),
                                        const SizedBox(width: 40,),
                                        Icon(
                                          CupertinoIcons.calendar,
                                          size: 20,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Edit end date 
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextWidget(text: "End date", fontSize: 14, fontWeight: FontWeight.w500),
                                  const SizedBox(height: 10,),
                                  ElevatedButton(
                                    iconAlignment: IconAlignment.end,
                                    onPressed: () async {
                                      DateTime? editEndTime = await showDatePicker(
                                        context: context, 
                                        firstDate: startDate!, 
                                        lastDate: DateTime(2100),
                                        initialDate: endDate,
                                        fieldLabelText: "End Date",
                                        helpText: "End Date",
                                      );
                                      if (editEndTime != null) {
                                        provider.updateEditLeave(editEndTime, false);
                                      }else{
                                        provider.updateEditLeave(null, false);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      backgroundColor: Colors.transparent.withOpacity(0.0),
                                      shadowColor: Colors.transparent.withOpacity(0.0),
                                      overlayColor: Colors.transparent.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color:Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8)
                                      )
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(
                                          text: provider.updatedEndTime != null
                                          ? DateFormat("dd MMM yyyy").format(provider.updatedEndTime!)
                                          : DateFormat("dd MMM yyyy").format(endDate!), 
                                          fontSize: 12, 
                                          fontColor: Colors.black,
                                          fontWeight: FontWeight.w400
                                        ),
                                        const SizedBox(width: 40,),
                                        Icon(
                                          CupertinoIcons.calendar,
                                          size: 20,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                             
                          ],
                        ),
                        const TextWidget(text: "Comments", fontSize: 14, fontWeight: FontWeight.w500),
                        const SizedBox(height: 10,),
                        TextFields(
                          isObseure: false, 
                          controller: commentsController,
                          textInputAction: TextInputAction.done,
                          // borderColor: provider.notSet && provider.commentsController.isEmpty ? Colors.red : null,
                        ),
                        const SizedBox(height: 10,),
                        // Update button
                        SizedBox(
                          width: double.infinity,
                          child: Consumer<ApiProvider>(
                            builder: (context, provider, child) {
                              return ButtonWidget(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                title: "Update" , 
                                onPressed: () async {
                                  Navigator.pop(sheetContext);
                                  await provider.editLeaveAPi(
                                    index: index, 
                                    leaveId: provider.leavesList[index].leaveId, 
                                    size: size, 
                                    context: screenContext,
                                    startDate: provider.updatedStartTime != null ? DateFormat("yyyy-MM-dd").format(provider.updatedStartTime!) : DateFormat("yyyy-MM-dd").format(startDate!), 
                                    endDate: provider.updatedEndTime != null ? DateFormat("yyyy-MM-dd").format(provider.updatedEndTime!): DateFormat("yyyy-MM-dd").format(endDate!), 
                                    comments: commentsController.text
                                  );
                                },
                              );
                            }
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
        );
      },
    );
  }

}