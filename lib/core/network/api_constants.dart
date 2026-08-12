class ApiConstants {
  ApiConstants._();

  static const baseUrl = "http://software.acumeninfra.org/webservice.asmx";
  static const apiBaseUrl = "$baseUrl/";
  static const customerBaseUrl = "https://software.acumeninfra.org/WebServiceCustomer.asmx";
  static const customerDashboardUrl = "$customerBaseUrl/Dashboard";
  static const customerBindPropertyUrl = "$customerBaseUrl/BindProperty";
  static const customerBindBlockUrl = "$customerBaseUrl/BindBlock";
  static const customerBindPlotUrl = "$customerBaseUrl/BindPlot";
  static const customerLedgerReportUrl = "$customerBaseUrl/Customerledger";
  static const customerProfileUrl = "$customerBaseUrl/CustomerProfile";

  static const getLogin = "$baseUrl/GetLogin";
  static const dashboardUrl = "$baseUrl/Dashboard";
  static const businessGraphUrl = "$baseUrl/BusinessGraph";
  static const selfBussinessReport = "$baseUrl/SelfBusiness";
  static const bookingDetailUrl = "$baseUrl/Bookingdetail";
  static const teamBusinessUrl = "$baseUrl/TeamBussiness";
  static const getProjectUrl = "$baseUrl/GetProject";
  static const getBlockUrl = "$baseUrl/GetBlock";
  static const getPlotUrl = "$baseUrl/Getplot";
  static const bindPropertyUrl = "$baseUrl/BindProperty";
  static const bindBlockUrl = "$baseUrl/BindBlock";
  static const bindPlotUrl = "$baseUrl/BindPlot";
  static const customerLedgerUrl = "$baseUrl/Customerledger";
  static const closingDateUrl = "$baseUrl/ClosingDate";
  static const payoutUrl = "$baseUrl/Payout";
  static const dstPayoutUrl = "$baseUrl/PayoutStatementDST";
  static const directIncomeDetailUrl = "$baseUrl/DirectIncomeDetail";
  static const paidPayoutDetailUrl = "$baseUrl/PaidPayoutDetail";
  static const rewardsStatusUrl = "$baseUrl/RewardsStatus";
  static const rewardIncomeDetailUrl = "$baseUrl/RewardIncomeDetail";
  static const myDirectDetailUrl = "$baseUrl/MyDirectDetailNew";
  static const associateLevelReportUrl = "$baseUrl/AssociateLevelreport";
  static const myDownlineUrl = "$baseUrl/Mydownline";
  static const getProfileUrl = "$baseUrl/GetProfile";
  static const updateKycUrl = "$baseUrl/UpdateKYC";
  static const treeViewBaseUrl =
      "http://software.acumeninfra.org/AssociateTreeviewapp.aspx";
  static const newAssociateBaseUrl =
      "http://software.acumeninfra.org/NewAssociate.aspx";
  static const welcomeLetterBaseUrl =
      "http://software.acumeninfra.org/WelcomeLetter.aspx";

  static String getTreeViewUrl(String userId) =>
      "$treeViewBaseUrl?username=$userId";

  static String getNewAssociateUrl(String userId) =>
      "$newAssociateBaseUrl?Id=$userId";

  static String getWelcomeLetterUrl(String userId) =>
      "$welcomeLetterBaseUrl?username=$userId";

  static const xApiKey = "x-api-key";
  static const xApiValue = "OPT-pCMr6da5EC2mC6p1OA8aW3znkrF2T3cg";
  static const authorization = "Authorization";
}

class ApiKeys {
  ApiKeys._();

  static const String success = "status";
  static const String response = "data";
  static const String message = "Message";
}
