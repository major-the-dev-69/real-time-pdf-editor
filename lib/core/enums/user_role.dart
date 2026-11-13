enum UserRole { superAdmin, admin, viewer, unknown }

extension UserRoleExtension on UserRole {
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'super-admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'viewer':
        return UserRole.viewer;
      default:
        return UserRole.unknown;
    }
  }

  String get value {
    switch (this) {
      case UserRole.superAdmin:
        return 'super-admin';
      case UserRole.admin:
        return 'admin';
      case UserRole.viewer:
        return 'viewer';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  bool get canViewProjects =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.viewer;
  bool get canCreateProject =>
      this == UserRole.superAdmin || this == UserRole.admin;
  bool get canEditProject =>
      this == UserRole.superAdmin || this == UserRole.admin;
  bool get canDeleteProject => this == UserRole.superAdmin;

  bool get canViewSites =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.viewer;
  bool get canCreateSite =>
      this == UserRole.superAdmin || this == UserRole.admin;
  bool get canEditSite =>
      this == UserRole.superAdmin || this == UserRole.admin;
  bool get canDeleteSite => this == UserRole.superAdmin;

  bool get canUploadPdf =>
      this == UserRole.superAdmin || this == UserRole.admin;
  bool get canViewPdf =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.viewer;

  bool get canDraw => this == UserRole.superAdmin || this == UserRole.admin;
  bool get canUndo => this == UserRole.superAdmin || this == UserRole.admin;
  bool get canRedo => this == UserRole.superAdmin || this == UserRole.admin;
  bool get canClearPage =>
      this == UserRole.superAdmin || this == UserRole.admin;
  bool get canClearAll => this == UserRole.superAdmin;
}
