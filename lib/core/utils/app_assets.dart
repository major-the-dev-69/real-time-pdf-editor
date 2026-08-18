import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AppAssets {
  AppAssets._();

  /// Images
  static const String _imgPrefix = 'assets/images';
  static const String imgAppLogo = '$_imgPrefix/app_logo.png';
  static const String imgBgScaffold = '$_imgPrefix/img_bg_scaffold.jpg';
  static const String imgTitleLogo = '$_imgPrefix/app_title_logo.png';
  static const String imgBgApp = '$_imgPrefix/bg_app.jpg';
  static const String imgAppTitle = '$_imgPrefix/app_title.png';
  static const String bgWaves = '$_imgPrefix/bg_waves.svg';
  static const String imgRealEstateVector = '$_imgPrefix/real_estate_vector.png';
  static const String imgCityWatermark = '$_imgPrefix/city_watermark.png';

  /// Icons
  static const String _iconPrefix = 'assets/icons';

  static const IconData backArrow = CupertinoIcons.back;
  static const IconData frontArrow = Icons.keyboard_arrow_right_rounded;
  static const IconData more = Icons.more_horiz_rounded;
  static const IconData home = CupertinoIcons.house_fill;
  static const String shop = '$_iconPrefix/ic_shop.svg';
  static const String icHearts = '$_iconPrefix/ic_heart.png';
  static const String icFilter = '$_iconPrefix/ic_filter.svg';
  static const String cake = '$_iconPrefix/ic_birthday.png';
  static const String edit = '$_iconPrefix/ic_edit.png';
  static const String forward = '$_iconPrefix/ic_forward.svg';
  static const String backword = '$_iconPrefix/ic_backword.svg';
  static const String svgIndianFlag = '$_iconPrefix/ic_indian_flag.svg';
  static const String bgCircleStroke = '$_iconPrefix/bg_circle_gap_stroke.svg';
  static const String google = '$_iconPrefix/ic_google.svg';

  /// Iconsax Icons - Auth & Common Navigation
  static const IconData icEmail = Iconsax.sms_copy;
  static const IconData icLock = Iconsax.lock_copy;
  static const IconData icEye = Iconsax.eye_copy;
  static const IconData icEyeSlash = Iconsax.eye_slash_copy;
  static const IconData icPhone = Iconsax.mobile_copy;
  static const IconData icArrowRight = Iconsax.arrow_right_3_copy;
  static const IconData icLogout = Iconsax.logout_copy;
  static const IconData icNotification = Iconsax.notification_copy;
  static const IconData icSearchNormal = Iconsax.search_normal_1_copy;
  static const IconData icCloseCircle = Iconsax.close_circle_copy;
  static const IconData icUser = Iconsax.user_copy;
  static const IconData icDiscover = Iconsax.discover_copy;

  /// Iconsax Icons - Dashboard & Real Estate
  static const IconData icDashboard = Iconsax.category_copy;
  static const IconData icBookings = Iconsax.bookmark_copy;
  static const IconData icIncomes = Iconsax.wallet_2_copy;
  static const IconData icKYC = Iconsax.shield_tick_copy;
  static const IconData icProperties = Iconsax.building_copy;
  static const IconData icBuilding = Iconsax.building_copy;
  static const IconData icBuildings = Iconsax.buildings_copy;
  static const IconData icStar = Iconsax.star_copy;
  static const IconData icCalendar = Iconsax.calendar_1_copy;
  static const IconData icDownload = Iconsax.import_copy;
  static const IconData icManageProperties = Iconsax.building_3_copy;
  static const IconData icTrackPerformance = Iconsax.status_up_copy;
  static const IconData icGrowNetwork = Iconsax.people_copy;

  /// Iconsax Icons - Sites & PDF Details
  static const IconData icPdf = Iconsax.document_text_copy;
  static const IconData icPdfFile = Iconsax.document_1_copy;
  static const IconData icLocationPin = Iconsax.location_copy;
  static const IconData icSiteMap = Iconsax.map_1_copy;
  static const IconData icFilterSearch = Iconsax.filter_search_copy;
  static const IconData icProjectBuilding = Iconsax.building_4_copy;
  static const IconData icDocumentDetail = Iconsax.document_text_1_copy;
  static const IconData icSharePdf = Iconsax.share_copy;
  static const IconData icDownloadPdf = Iconsax.import_1_copy;
  static const IconData icEyeView = Iconsax.eye_copy;
  static const IconData icPinHeader = Iconsax.attach_circle_copy;
  static const IconData icSearch = Iconsax.search_normal_1_copy;
  static const IconData icFilterTag = Iconsax.setting_4_copy;
  static const IconData icTickCircle = Iconsax.tick_circle_copy;
  static const IconData icEditPen = Iconsax.edit_2_copy;

  /// Animations
  static const String _animPrefix = 'assets/anim';
  static const String animLoader1 = '$_animPrefix/loader_spinner.json';
  static const String animWomen = '$_animPrefix/anim_1.json';
  static const String animMan = '$_animPrefix/anim_2.json';
}
