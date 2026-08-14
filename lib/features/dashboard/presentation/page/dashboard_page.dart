import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/dashboard_controller.dart';
import '../widgets/pdf_list_item.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/project_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Dummy Data for UI presentation
    final dummyProjects = [
      {
        'title': 'Modern E-commerce App',
        'image':
            'https://images.unsplash.com/photo-1522204523234-8729aa6e3d5f?q=80&w=2070&auto=format&fit=crop',
      },
      {
        'title': 'Fintech Dashboard',
        'image':
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070&auto=format&fit=crop',
      },
      {
        'title': 'Social Media Redesign',
        'image':
            'https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=1974&auto=format&fit=crop',
      },
    ];

    final dummyPdfs = [
      {
        'title': 'Q3 Financial Report.pdf',
        'details': 'Updated 2 hours ago • 2.4 MB',
      },
      {
        'title': 'Project Requirements.pdf',
        'details': 'Updated yesterday • 1.1 MB',
      },
      {
        'title': 'Brand Guidelines v2.pdf',
        'details': 'Updated 3 days ago • 5.7 MB',
      },
      {
        'title': 'Client Presentation.pdf',
        'details': 'Updated last week • 3.2 MB',
      },
    ];

    final dummyAvatars = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=1976&auto=format&fit=crop',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DashboardHeader(
                userName: 'Vibhav',
                onNotificationTap: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Projects',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('See All')),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: dummyProjects.length,
                  itemBuilder: (context, index) {
                    final project = dummyProjects[index];
                    return ProjectCard(
                      title: project['title']!,
                      imageUrl: project['image']!,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Shared PDFs',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final pdf = dummyPdfs[index];
                  return PdfListItem(
                    title: pdf['title']!,
                    details: pdf['details']!,
                    avatarUrls: dummyAvatars,
                  );
                }, childCount: dummyPdfs.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
