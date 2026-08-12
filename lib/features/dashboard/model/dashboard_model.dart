class DashboardModel {
  final String status;
  final String agentId;
  final String mobile;
  final String address;
  final double packagePrice;
  final String kycStatus;
  final String agentName;
  final String currDate;
  final String joinDate;
  final String? sponsorName;
  final String activationDate;
  final String sponsorId;
  final String position;
  final int rankPost;
  final String? photo;
  final int dInActive;
  final int dActive;
  final int tActive;
  final int tInActive;
  final double paidAmt;
  final double deduction;
  final double balance;
  final int myDirect;
  final int myTeam;
  final double directIncome;
  final double levelIncome;
  final double poolIncome;
  final double income;
  final double selfBusiness;
  final double directIncomeP;
  final double levelIncomeP;
  final double salIncome;
  final double rewardIncome;
  final double teamBusiness;
  final double totalPlotCast;
  final double totalArea;
  final double roiIncome;
  final double clubIncome;
  final String rewardName;
  final double totPackageAmount;
  final String? popupImage;

  DashboardModel({
    required this.status,
    required this.agentId,
    required this.mobile,
    required this.address,
    required this.packagePrice,
    required this.kycStatus,
    required this.agentName,
    required this.currDate,
    required this.joinDate,
    this.sponsorName,
    required this.activationDate,
    required this.sponsorId,
    required this.position,
    required this.rankPost,
    this.photo,
    required this.dInActive,
    required this.dActive,
    required this.tActive,
    required this.tInActive,
    required this.paidAmt,
    required this.deduction,
    required this.balance,
    required this.myDirect,
    required this.myTeam,
    required this.directIncome,
    required this.levelIncome,
    required this.poolIncome,
    required this.income,
    required this.selfBusiness,
    required this.directIncomeP,
    required this.levelIncomeP,
    required this.salIncome,
    required this.rewardIncome,
    required this.teamBusiness,
    required this.totalPlotCast,
    required this.totalArea,
    required this.roiIncome,
    required this.clubIncome,
    required this.rewardName,
    required this.totPackageAmount,
    this.popupImage,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return DashboardModel(
      status: json['Status']?.toString() ?? 'Active',
      agentId: json['agentid']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      packagePrice: parseDouble(json['PackagePrice']),
      kycStatus: json['KYC_Status']?.toString() ?? '',
      agentName: json['agentname']?.toString() ?? '',
      currDate: json['currdate']?.toString() ?? '',
      joinDate: json['joindate']?.toString() ?? '',
      sponsorName: json['sponsorname']?.toString(),
      activationDate: json['ActivationDate']?.toString() ?? '',
      sponsorId: json['SponsorId']?.toString() ?? '',
      position: json['Position']?.toString() ?? '',
      rankPost: parseInt(json['RankPost']),
      photo: json['Photo']?.toString(),
      dInActive: parseInt(json['DInActive']),
      dActive: parseInt(json['DActive']),
      tActive: parseInt(json['TActive']),
      tInActive: parseInt(json['TInActive']),
      paidAmt: parseDouble(json['Paidamt']),
      deduction: parseDouble(json['deduction']),
      balance: parseDouble(json['balance']),
      myDirect: parseInt(json['MyDirect']),
      myTeam: parseInt(json['MyTeam']),
      directIncome: parseDouble(json['directincome']),
      levelIncome: parseDouble(json['levelincome']),
      poolIncome: parseDouble(json['poolincome']),
      income: parseDouble(json['income']),
      selfBusiness: parseDouble(json['selfbusiness']),
      directIncomeP: parseDouble(json['directincomeP']),
      levelIncomeP: parseDouble(json['levelincomeP']),
      salIncome: parseDouble(json['salincome']),
      rewardIncome: parseDouble(json['rewardIncome']),
      teamBusiness: parseDouble(json['teambusiness']),
      totalPlotCast: parseDouble(json['TotalPlotcast']),
      totalArea: parseDouble(json['TotalArea']),
      roiIncome: parseDouble(json['ROIIncome']),
      clubIncome: parseDouble(json['ClubIncome']),
      rewardName: json['RewardName']?.toString() ?? 'N/A',
      totPackageAmount: parseDouble(json['Totpackageamount']),
      popupImage: json['PopupImage']?.toString(),
    );
  }


  double get totalBusiness => selfBusiness + teamBusiness;
}
