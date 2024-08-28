import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
              int differnece = DateTime.parse(provider.editedEndDate[index].isNotEmpty ? provider.editedEndDate[index] : provider.leavesList[index].endDate).difference(DateTime.parse(provider.editedStartDate[index].isNotEmpty ? provider.editedStartDate[index] : provider.leavesList[index].startDate)).inDays;
              String startDate = DateFormat("dd MMM ''yy").format(DateTime.parse(provider.editedStartDate[index].isNotEmpty ? provider.editedStartDate[index] : provider.leavesList[index].startDate));
              String endDate = DateFormat("dd MMM ''yy").format(DateTime.parse(provider.editedEndDate[index].isNotEmpty ? provider.editedEndDate[index] :provider.leavesList[index].endDate));
              return Column(
                children: [
                  Container(
                    height: provider.isEdited[index] 
                    ? size.height * 0.15
                    : null,
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
                            TextWidget(
                              text: differnece == 0 
                                ? 'One day application'
                                : '${differnece+1} days application', 
                              fontWeight: FontWeight.w500, 
                              fontSize: 16,
                              fontColor: Colors.grey,
                            ),
                            // Icons
                            Row(
                              children: [
                                // Edit Icon
                                provider.isEdited[index]
                                ? GestureDetector(
                                  onTap: (){
                                    provider.cancelLeave(index);
                                  },
                                  child: const Icon(CupertinoIcons.xmark, size: 20,),
                                )
                                :  GestureDetector(
                                  onTap: () async {
                                    // Change state of this widget to editing
                                    provider.editLeave(index);
                                    // PIck Edit Start Date
                                    DateTime? editStartDate = await showDatePicker(
                                      context: context, 
                                      firstDate: DateTime.now(), 
                                      lastDate: DateTime(2100),
                                      initialDate: DateTime.parse(provider.editedStartDate[index].isNotEmpty ? provider.editedStartDate[index] :provider.leavesList[index].startDate),
                                      fieldLabelText: "Start Date",
                                      helpText: "Start Date",
                                    );
                                      /// Check if the start date is null, and if so, set [provider.editedStartDate[index]] accordingly.
                                      editStartDate != null 
                                        ? provider.editedStartDate[index] = DateFormat("yyyy-MM-dd").format(editStartDate)
                                        : provider.editedStartDate[index] = '';
                                      /// If the [editedStartDate[index]] is empty it means the [editStartDate] returned null.
                                      /// and the editing opertion is cancelled, if so, continuing edit opertion.
                                      provider.editedStartDate[index].isEmpty 
                                      ? provider.isEdited[index] = !provider.isEdited[index] 
                                      : provider.isEdited[index] = true;
                                    print('StartTime: ${provider.editedStartDate[index]}');
                                    // Edit End Time
                                    if (editStartDate != null) {
                                      DateTime? editEndTime = await showDatePicker(
                                        context: context, 
                                        firstDate: DateTime.now(), 
                                        lastDate: DateTime(2100),
                                        initialDate: DateTime.parse(provider.editedEndDate[index].isNotEmpty ? provider.editedEndDate[index] :provider.leavesList[index].endDate),
                                        fieldLabelText: "End Date",
                                        helpText: "End Date",
                                      );
                                      /// Check if the start date is null, and if so, set [editEndTime] accordingly.
                                      editEndTime != null 
                                        ? provider.editedEndDate[index] = DateFormat("yyyy-MM-dd").format(editEndTime)
                                        : provider.editedEndDate[index] = "";
                                      /// If the [provider.editedEndDate[index]] is empty it means the [editEndTime] returned null
                                      /// and the editing opertion is cancelled, if so, continuing edit opertion.
                                      provider.editedEndDate[index].isEmpty 
                                        ? provider.isEdited[index] = !provider.isEdited[index] 
                                        : provider.isEdited[index] = true;
                                    
                                      print('End Time: $provider.editedEndDate[index]');
                                    }
                                  }, 
                                  child: const Icon(CupertinoIcons.pencil)
                                ),
                                const SizedBox(width: 8,),
                                GestureDetector(
                                  onTap: () async {
                                    provider.isEdited[index]
                                    ? await provider.editLeaveAPi(
                                        index: index, 
                                        leaveId: provider.leavesList[index].leaveId, 
                                        size: size, 
                                        context: context,
                                        startDate: provider.editedStartDate[index].isEmpty ? provider.leavesList[index].startDate : provider.editedStartDate[index], 
                                        endDate: provider.editedEndDate[index].isEmpty ? provider.leavesList[index].endDate : provider.editedEndDate[index], 
                                        comments: provider.commentsController[index].text.isEmpty ? provider.leavesList[index].comments : provider.commentsController[index].text
                                      )
                                    : provider.confirmDeleteLeave(context, size, provider.leavesList[index].leaveId, index);
                                    
                                  }, 
                                  child: Icon(
                                    provider.isEdited[index] 
                                    ?  CupertinoIcons.floppy_disk 
                                    : CupertinoIcons.delete_simple,
                                    size: 20,
                                    color: !provider.isEdited[index] ? Colors.red : Colors.black,
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
                        provider.isEdited[index] ? const SizedBox(height: 15,) : const SizedBox(),
                        // Comments
                        provider.isEdited[index] 
                        ? SizedBox(
                          width: size.width * 0.6,
                          height: 10,
                          child: TextField(
                            controller: provider.commentsController[index],
                            cursorHeight: 18,
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey
                                )
                              )
                            ),
                          ),
                        )
                        : SizedBox(
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
}