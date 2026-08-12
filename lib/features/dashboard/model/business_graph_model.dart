class BusinessGraphModel {
  final int payYear;
  final int payMonth;
  final String businessPeriod;
  final int periodNo;
  final double business;

  BusinessGraphModel({
    required this.payYear,
    required this.payMonth,
    required this.businessPeriod,
    required this.periodNo,
    required this.business,
  });

  factory BusinessGraphModel.fromJson(Map<String, dynamic> json) {
    return BusinessGraphModel(
      payYear: (json['PayYear'] as num?)?.toInt() ??
          int.tryParse(json['PayYear']?.toString() ?? '0') ??
          0,
      payMonth: (json['PayMonth'] as num?)?.toInt() ??
          int.tryParse(json['PayMonth']?.toString() ?? '0') ??
          0,
      businessPeriod: json['BusinessPeriod']?.toString() ?? '',
      periodNo: (json['PeriodNo'] as num?)?.toInt() ??
          int.tryParse(json['PeriodNo']?.toString() ?? '0') ??
          0,
      business: (json['Business'] as num?)?.toDouble() ??
          double.tryParse(json['Business']?.toString() ?? '0') ??
          0.0,
    );
  }

  String get formattedFullBusiness => '₹ ${business.toStringAsFixed(2)}';

  String get compactBusiness {
    if (business >= 10000000) {
      return '${(business / 10000000).toStringAsFixed(2)} Cr';
    } else if (business >= 100000) {
      return '${(business / 100000).toStringAsFixed(2)} L';
    } else if (business >= 1000) {
      return '${(business / 1000).toStringAsFixed(1)} K';
    }
    return business.toStringAsFixed(0);
  }
}
