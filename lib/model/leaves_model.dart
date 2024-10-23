class LeavesModel{
  final int leaveId;
  final String startDate;
  final String endDate;
  final String comments;
  final String? status;

  LeavesModel({
    required this.leaveId,
    required this.startDate,
    required this.endDate,
    required this.comments,
    this.status,
  });

  Map<String, dynamic> toMap(){
    final results = <String, dynamic>{};
    results.addAll({"leave_id": leaveId});
    results.addAll({"start_date":startDate});
    results.addAll({"end_date":endDate});
    results.addAll({"comments":comments});

    return results;
  }

  factory LeavesModel.fromMap(Map<String, dynamic> map){
    return LeavesModel(
      leaveId: map["leave_id"], 
      startDate: map["start_date"], 
      endDate: map["end_date"], 
      comments: map["comments"],
      status: map["status"]
    );
  }
}