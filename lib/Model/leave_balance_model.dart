class LeaveBalanceModel {
  final int casualLeave;
  final int sickLeave;
  final int annualLeave;

  LeaveBalanceModel({
    required this.casualLeave,
    required this.sickLeave,
    required this.annualLeave,
  });

  // Add a fromJson factory if your API returns JSON
  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      casualLeave: json['casual_leave_balance'],
      sickLeave: json['sick_leave_balance'],
      annualLeave: json['annual_leave_balance'],
    );
  }
}
