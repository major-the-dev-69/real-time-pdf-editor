import 'package:get/get.dart';
import '../../model/real_estate_project_model.dart';
import '../../../pdf/model/pdf_document_model.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  // Real Estate Projects List
  final projectsList = <RealEstateProject>[].obs;
  
  // All PDF Documents
  final allPdfs = <PdfDocumentModel>[].obs;

  // Filter States
  final selectedProjectId = 'all'.obs;
  final selectedSiteId = 'all'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void _loadInitialData() {
    // Populate dummy Real Estate Projects with Site Names
    projectsList.assignAll([
      RealEstateProject(
        id: 'proj_1',
        title: 'Grand Horizon Towers',
        location: 'Sector 62, Gurgaon',
        imageUrl:
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=1935&auto=format&fit=crop',
        siteCount: 3,
        pdfCount: 4,
        status: 'Active',
        sites: const [
          SiteName(
            id: 'site_101',
            projectId: 'proj_1',
            name: 'Tower A - Master Plan',
            code: 'T-A',
            pdfCount: 2,
          ),
          SiteName(
            id: 'site_102',
            projectId: 'proj_1',
            name: 'Tower B - Luxury Suites',
            code: 'T-B',
            pdfCount: 1,
          ),
          SiteName(
            id: 'site_103',
            projectId: 'proj_1',
            name: 'Commercial Plaza',
            code: 'CP-1',
            pdfCount: 1,
          ),
        ],
      ),
      RealEstateProject(
        id: 'proj_2',
        title: 'PBD Sky City Enclave',
        location: 'Airport Road, Mohali',
        imageUrl:
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=2070&auto=format&fit=crop',
        siteCount: 3,
        pdfCount: 3,
        status: 'Under Construction',
        sites: const [
          SiteName(
            id: 'site_201',
            projectId: 'proj_2',
            name: 'Phase 1 - Residential Plots',
            code: 'P1-RES',
            pdfCount: 1,
          ),
          SiteName(
            id: 'site_202',
            projectId: 'proj_2',
            name: 'Phase 2 - Villa Layouts',
            code: 'P2-VIL',
            pdfCount: 1,
          ),
          SiteName(
            id: 'site_203',
            projectId: 'proj_2',
            name: 'Club House & Amenities',
            code: 'CLUB',
            pdfCount: 1,
          ),
        ],
      ),
      RealEstateProject(
        id: 'proj_3',
        title: 'Emerald Valley Heights',
        location: 'SG Highway, Ahmedabad',
        imageUrl:
            'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=2070&auto=format&fit=crop',
        siteCount: 2,
        pdfCount: 3,
        status: 'Newly Launched',
        sites: const [
          SiteName(
            id: 'site_301',
            projectId: 'proj_3',
            name: 'Block Alpha - Highrise',
            code: 'BLK-A',
            pdfCount: 2,
          ),
          SiteName(
            id: 'site_302',
            projectId: 'proj_3',
            name: 'Green Belt Park Layout',
            code: 'PARK',
            pdfCount: 1,
          ),
        ],
      ),
    ]);

    // Populate Real Estate PDF Documents according to project & site names
    allPdfs.assignAll([
      const PdfDocumentModel(
        id: 'pdf_1',
        title: 'Tower A Floor Plan & Brochure.pdf',
        projectId: 'proj_1',
        projectName: 'Grand Horizon Towers',
        siteId: 'site_101',
        siteName: 'Tower A - Master Plan',
        fileSize: '3.4 MB',
        updatedAt: 'Updated 2 hrs ago',
        pageCount: 14,
        pdfUrl: 'https://example.com/pdf1.pdf',
        category: 'Floor Plan',
        description:
            'Comprehensive architectural floor plan blueprint and detailed layout specification sheet for Tower A luxury apartments.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_2',
        title: 'Approved Site NOC & Master Blueprint.pdf',
        projectId: 'proj_1',
        projectName: 'Grand Horizon Towers',
        siteId: 'site_101',
        siteName: 'Tower A - Master Plan',
        fileSize: '5.1 MB',
        updatedAt: 'Updated Yesterday',
        pageCount: 8,
        pdfUrl: 'https://example.com/pdf2.pdf',
        category: 'Legal Approval',
        description:
            'Government approved sanction certificate, fire NOC, and master structural blueprint documentation for Tower A site.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_3',
        title: 'Tower B Suite Pricing & Payment Terms.pdf',
        projectId: 'proj_1',
        projectName: 'Grand Horizon Towers',
        siteId: 'site_102',
        siteName: 'Tower B - Luxury Suites',
        fileSize: '1.8 MB',
        updatedAt: 'Updated 3 days ago',
        pageCount: 5,
        pdfUrl: 'https://example.com/pdf3.pdf',
        category: 'Pricing Sheet',
        description:
            'Official price list, payment schedules, installment options, and booking guidelines for Tower B luxury suites.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=1976&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_4',
        title: 'Commercial Plaza Retail Layout.pdf',
        projectId: 'proj_1',
        projectName: 'Grand Horizon Towers',
        siteId: 'site_103',
        siteName: 'Commercial Plaza',
        fileSize: '4.2 MB',
        updatedAt: 'Updated 4 days ago',
        pageCount: 10,
        pdfUrl: 'https://example.com/pdf4.pdf',
        category: 'Site Map',
        description:
            'Retail outlet dimensions, footfall projection map, and commercial plaza floor layout details.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_5',
        title: 'Phase 1 Plot Dimensions & Site Map.pdf',
        projectId: 'proj_2',
        projectName: 'PBD Sky City Enclave',
        siteId: 'site_201',
        siteName: 'Phase 1 - Residential Plots',
        fileSize: '6.5 MB',
        updatedAt: 'Updated Today',
        pageCount: 18,
        pdfUrl: 'https://example.com/pdf5.pdf',
        category: 'Plot Layout',
        description:
            'Dimensions, facing directions, road widths, and availability status for Phase 1 residential plot allotment.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_6',
        title: 'Villa Design Catalogs & Specifications.pdf',
        projectId: 'proj_2',
        projectName: 'PBD Sky City Enclave',
        siteId: 'site_202',
        siteName: 'Phase 2 - Villa Layouts',
        fileSize: '7.2 MB',
        updatedAt: 'Updated 5 days ago',
        pageCount: 22,
        pdfUrl: 'https://example.com/pdf6.pdf',
        category: 'Catalog',
        description:
            '3D elevation models, architectural design catalog, and material specifications for Phase 2 duplex villas.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_7',
        title: 'Club House Facilities & Layout Plan.pdf',
        projectId: 'proj_2',
        projectName: 'PBD Sky City Enclave',
        siteId: 'site_203',
        siteName: 'Club House & Amenities',
        fileSize: '2.9 MB',
        updatedAt: 'Updated Last Week',
        pageCount: 6,
        pdfUrl: 'https://example.com/pdf7.pdf',
        category: 'Amenities',
        description:
            'Clubhouse architectural layout, swimming pool dimensions, gymnasium layout, and membership details.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=1976&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_8',
        title: 'Block Alpha Highrise Structure Plan.pdf',
        projectId: 'proj_3',
        projectName: 'Emerald Valley Heights',
        siteId: 'site_301',
        siteName: 'Block Alpha - Highrise',
        fileSize: '4.8 MB',
        updatedAt: 'Updated 1 day ago',
        pageCount: 16,
        pdfUrl: 'https://example.com/pdf8.pdf',
        category: 'Structural Plan',
        description:
            'Earthquake resistant structural engineering blueprint and foundation layout for Block Alpha highrise.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_9',
        title: 'Block Alpha RERA Registration Doc.pdf',
        projectId: 'proj_3',
        projectName: 'Emerald Valley Heights',
        siteId: 'site_301',
        siteName: 'Block Alpha - Highrise',
        fileSize: '1.2 MB',
        updatedAt: 'Updated 2 days ago',
        pageCount: 4,
        pdfUrl: 'https://example.com/pdf9.pdf',
        category: 'Legal Approval',
        description:
            'State RERA approval registration certificate and compliance report for Block Alpha.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop',
        ],
      ),
      const PdfDocumentModel(
        id: 'pdf_10',
        title: 'Green Belt Landscape Master Plan.pdf',
        projectId: 'proj_3',
        projectName: 'Emerald Valley Heights',
        siteId: 'site_302',
        siteName: 'Green Belt Park Layout',
        fileSize: '3.9 MB',
        updatedAt: 'Updated 3 days ago',
        pageCount: 7,
        pdfUrl: 'https://example.com/pdf10.pdf',
        category: 'Landscape',
        description:
            'Botanical garden layout, walking track plan, and central park landscape master plan.',
        sharedAvatars: [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop',
        ],
      ),
    ]);
  }

  // Get available sites based on selected project
  List<SiteName> get availableSites {
    if (selectedProjectId.value == 'all') {
      return projectsList.expand((proj) => proj.sites).toList();
    }
    final project = projectsList.firstWhere(
      (p) => p.id == selectedProjectId.value,
      orElse: () => projectsList.first,
    );
    return project.sites;
  }

  // Filtered PDFs computed property
  List<PdfDocumentModel> get filteredPdfs {
    return allPdfs.where((pdf) {
      // Project Filter
      if (selectedProjectId.value != 'all' &&
          pdf.projectId != selectedProjectId.value) {
        return false;
      }
      // Site Filter
      if (selectedSiteId.value != 'all' &&
          pdf.siteId != selectedSiteId.value) {
        return false;
      }
      // Search Query Filter
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.toLowerCase().trim();
        final matchesTitle = pdf.title.toLowerCase().contains(query);
        final matchesProject = pdf.projectName.toLowerCase().contains(query);
        final matchesSite = pdf.siteName.toLowerCase().contains(query);
        final matchesCategory = pdf.category.toLowerCase().contains(query);
        return matchesTitle || matchesProject || matchesSite || matchesCategory;
      }
      return true;
    }).toList();
  }

  void selectProject(String id) {
    if (selectedProjectId.value == id) return;
    selectedProjectId.value = id;
    selectedSiteId.value = 'all'; // Reset site selection on project change
  }

  void selectSite(String id) {
    selectedSiteId.value = id;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearFilters() {
    selectedProjectId.value = 'all';
    selectedSiteId.value = 'all';
    searchQuery.value = '';
  }
}
