import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../backend/services/auth_service.dart';
import '../../profile/models/profile_state.dart';
import '../domain/entities/contributor_item.dart';
import '../presentation/bloc/contributor_bloc.dart';
import '../presentation/bloc/contributor_event.dart';
import '../presentation/bloc/contributor_state.dart';
import '../presentation/widgets/contributor_painters.dart';
import '../presentation/widgets/tech_radar_avatar.dart';
import '../presentation/widgets/pulsing_status_light.dart';
import '../presentation/widgets/cyber_mainframe_header.dart';
import '../presentation/widgets/add_edit_contributor_sheet.dart';

class ContributorsScreen extends StatefulWidget {
  const ContributorsScreen({super.key});

  @override
  State<ContributorsScreen> createState() => _ContributorsScreenState();
}

class _ContributorsScreenState extends State<ContributorsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<ContributorBloc>().add(const FetchContributorsRequested());
  }

  Future<void> _refresh() async {
    context.read<ContributorBloc>().add(const FetchContributorsRequested(forceRefresh: true));
  }

  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri? url = Uri.tryParse(urlString);
    if (url != null) {
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open link: $urlString')),
          );
        }
      }
    }
  }

  void _showAddEditContributorSheet([ContributorItem? contributor]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditContributorSheet(contributor: contributor),
    );
  }

  Future<void> _confirmDeleteContributor(ContributorItem contributor) async {
    final colors = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Contributor'),
          content: Text('Are you sure you want to remove ${contributor.name} from the contributors board?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: colors.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      context.read<ContributorBloc>().add(DeleteContributorRequested(contributor));
    }
  }

  Color _getFuturisticColor(String role) {
    final r = role.toLowerCase();
    if (r.contains('dev') || r.contains('backend') || r.contains('frontend') || r.contains('code') || r.contains('engine')) {
      return const Color(0xFF00ADB5); // Futuristic Cyber Teal
    }
    if (r.contains('design') || r.contains('ui') || r.contains('ux') || r.contains('graphics') || r.contains('art')) {
      return const Color(0xFFE53935); // Crimson Synth Red
    }
    if (r.contains('president') || r.contains('lead') || r.contains('head') || r.contains('vp') || r.contains('manager')) {
      return const Color(0xFFFFB300); // Amber Gold
    }
    return const Color(0xFF43A047); // Neon Matrix Green
  }

  IconData _getRoleIcon(String role) {
    final r = role.toLowerCase();
    if (r.contains('dev') || r.contains('backend') || r.contains('frontend') || r.contains('code') || r.contains('engine')) {
      return Icons.terminal;
    }
    if (r.contains('design') || r.contains('ui') || r.contains('ux') || r.contains('graphics') || r.contains('art')) {
      return Icons.palette_outlined;
    }
    if (r.contains('president') || r.contains('lead') || r.contains('vp') || r.contains('head') || r.contains('manager')) {
      return Icons.security;
    }
    return Icons.military_tech_outlined;
  }

  Widget _buildGithubIcon({double size = 16, Color color = Colors.black}) {
    return CustomPaint(
      size: Size(size, size),
      painter: GithubPainter(color),
    );
  }

  Widget _buildLinkedInIcon({double size = 16}) {
    return CustomPaint(
      size: Size(size, size),
      painter: LinkedInPainter(const Color(0xFF0077B5)),
    );
  }

  Widget _buildSocialPillButton({
    required Widget logo,
    required String label,
    required Color brandColor,
    required VoidCallback onPressed,
  }) {
    final isNight = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    final textAndIconColor = isNight 
        ? (brandColor == Colors.black ? colors.onSurface : (brandColor == Colors.white ? Colors.white : brandColor))
        : (brandColor == Colors.white ? Colors.black87 : brandColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isNight
                ? brandColor.withOpacity(0.06)
                : brandColor.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: brandColor.withOpacity(isNight ? 0.3 : 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: brandColor.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              logo,
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: textAndIconColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticHeader(List<ContributorItem> contributors) {
    final colors = Theme.of(context).colorScheme;
    final isNight = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNight 
              ? [colors.primary.withOpacity(0.12), colors.surfaceContainer.withOpacity(0.1)]
              : [colors.primary.withOpacity(0.06), colors.surfaceContainer.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.hub_outlined, color: colors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEVELOPER CORE MAINFRAME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'System Architecture & Contributors',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem('CORE DEVELOPERS', '${contributors.length}', const Color(0xFF00ADB5)),
              _buildMetricItem('SYSTEM VERSION', 'v1.0.1', const Color(0xFFFFB300)),
              _buildMetricItem('MAINFRAME STATUS', 'OPERATIONAL', const Color(0xFF43A047), pulsate: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color accentColor, {bool pulsate = false}) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: colors.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (pulsate)
              PulsingStatusLight(color: accentColor)
            else
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isNight = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Contributors',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh Board',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurface.withOpacity(0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(Icons.menu_book_outlined, size: 20),
              text: 'Our Journey',
            ),
            Tab(
              icon: Icon(Icons.hub_outlined, size: 20),
              text: 'Dev Mainframe',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: OUR JOURNEY & VISION
          _buildJourneyTab(colors, isNight),

          // TAB 2: KEY CONTRIBUTORS & DEV TEAM
          RefreshIndicator(
            onRefresh: _refresh,
            child: BlocConsumer<ContributorBloc, ContributorState>(
              listener: (context, state) {
                if (state is ContributorError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else if (state is ContributorOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ContributorLoading || state is ContributorInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                List<ContributorItem> contributors = [];
                if (state is ContributorsLoaded) {
                  contributors = state.contributors;
                }

                if (contributors.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_outlined, size: 64, color: colors.onSurface.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No contributors added yet.',
                              style: TextStyle(fontSize: 16, color: colors.onSurface.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                
                final isWide = MediaQuery.of(context).size.width > 600;
                if (isWide) {
                  final leftCol = <ContributorItem>[];
                  final rightCol = <ContributorItem>[];
                  for (int i = 0; i < contributors.length; i++) {
                    if (i % 2 == 0) {
                      leftCol.add(contributors[i]);
                    } else {
                      rightCol.add(contributors[i]);
                    }
                  }
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: CyberMainframeHeader(
                            contributors: contributors,
                            builder: (context, list) => _buildFuturisticHeader(list),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: leftCol.map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildContributorCard(c),
                                  )).toList(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: rightCol.map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildContributorCard(c),
                                  )).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: CyberMainframeHeader(
                            contributors: contributors,
                            builder: (context, list) => _buildFuturisticHeader(list),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final contributor = contributors[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildContributorCard(contributor),
                              );
                            },
                            childCount: contributors.length,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<ProfileData>(
        valueListenable: currentProfile,
        builder: (context, profile, _) {
          final isAdmin = profile.role != UserRole.student;
          if (!isAdmin) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showAddEditContributorSheet(),
            icon: const Icon(Icons.add),
            label: const Text('Add Contributor'),
          );
        },
      ),
    );
  }

  Widget _buildContributorCard(ContributorItem contributor) {
    final colors = Theme.of(context).colorScheme;
    final isNight = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = currentProfile.value.role != UserRole.student;
    
    final futuristicColor = _getFuturisticColor(contributor.role);

    return CustomPaint(
      foregroundPainter: HUDCornerPainter(futuristicColor.withOpacity(0.4)),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: futuristicColor.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: futuristicColor.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [futuristicColor, futuristicColor.withOpacity(0.2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TechRadarAvatar(
                    imagePath: contributor.imagePath,
                    name: contributor.name,
                    themeColor: futuristicColor,
                    radius: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contributor.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (isAdmin) const SizedBox(width: 72),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: futuristicColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: futuristicColor.withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getRoleIcon(contributor.role),
                                size: 11,
                                color: futuristicColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  contributor.role.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: futuristicColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (contributor.contribution.isNotEmpty) ...[
                          Text(
                            contributor.contribution,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: colors.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (contributor.githubUrl.isNotEmpty || contributor.linkedinUrl.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (contributor.githubUrl.isNotEmpty)
                                _buildSocialPillButton(
                                  logo: _buildGithubIcon(
                                    size: 14,
                                    color: isNight ? Colors.white : Colors.black,
                                  ),
                                  label: 'GITHUB',
                                  brandColor: isNight ? Colors.white : Colors.black,
                                  onPressed: () => _launchURL(contributor.githubUrl),
                                ),
                              if (contributor.linkedinUrl.isNotEmpty)
                                _buildSocialPillButton(
                                  logo: _buildLinkedInIcon(size: 14),
                                  label: 'LINKEDIN',
                                  brandColor: const Color(0xFF0077B5),
                                  onPressed: () => _launchURL(contributor.linkedinUrl),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
                      onPressed: () => _showAddEditContributorSheet(contributor),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Edit Contributor',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                      onPressed: () => _confirmDeleteContributor(contributor),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete Contributor',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyTab(ColorScheme colors, bool isNight) {
    final storyTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: colors.primary,
      letterSpacing: 0.5,
    );
    
    final storyBodyStyle = TextStyle(
      fontSize: 13.5,
      height: 1.55,
      color: colors.onSurface.withOpacity(0.85),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Futuristic Intro Main Quote Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withOpacity(isNight ? 0.12 : 0.06),
                  colors.surfaceContainer.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withOpacity(0.2), width: 1.2),
            ),
            child: Column(
              children: [
                Icon(Icons.rocket_launch_outlined, color: colors.primary, size: 36),
                const SizedBox(height: 14),
                Text(
                  '"Together, we are not just building an application, we are building the future of our department."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: colors.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Journey Milestones Timeline
          Text(
            'CHRONOLOGY OF INNOVATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTimelineNode(
            year: '2023',
            title: 'THE SPARK & FOUNDATION',
            description: 'The first Computer Programming Club established at Shyamoli Engineering College. Passionate student pioneers envisioned a unified CSE Department community.',
            colors: colors,
            icon: Icons.lightbulb_outline,
          ),
          _buildTimelineNode(
            year: '2025',
            title: 'THE BOLD INITIATIVE',
            description: 'Crypton2 took the bold initiative to design and program a unique, fully custom application to serve both the department and the club.',
            colors: colors,
            icon: Icons.code,
          ),
          _buildTimelineNode(
            year: '2026',
            title: 'DIGITAL ERA REALIZED',
            description: 'The official launch of ShEC CSE Application! Making CSE the first department of Shyamoli Engineering College to introduce its own official portal to automate activities.',
            colors: colors,
            icon: Icons.verified_user_outlined,
            isLast: true,
          ),
          
          const SizedBox(height: 24),

          // 3. Editorial Narrative Essay
          _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history_edu, color: colors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text('THE CRYPTON2 NARRATIVE', style: storyTitleStyle),
                    ],
                  ),
                  const Divider(height: 28),
                  Text(
                    'By The Grace of Almighty, after countless discussions, sleepless nights, and relentless dedication, a new era is finally beginning at Shyamoli Engineering College through the initiative of Crypton2.',
                    style: storyBodyStyle,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'As we all know, the first Computer Programming Club at Shyamoli Engineering College was established in 2023. From the very beginning, a group of passionate students from Crypton2 envisioned creating a unified platform that could connect every batch of our beloved CSE Department under one community.',
                    style: storyBodyStyle,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'With that vision in mind, in 2024, Crypton2 took the bold initiative to develop a unique and dedicated application for both our department and the club. Today, that vision has become a reality with the launch of the Shyamoli Engineering College CSE Application, a platform where all students can stay connected, collaborate, and engage with one another seamlessly.',
                    style: storyBodyStyle,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Through this remarkable achievement, the CSE Department proudly becomes the first department of Shyamoli Engineering College to introduce its own official application, aiming to modernize and automate departmental activities in alignment with the demands of the digital era.',
                    style: storyBodyStyle,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Every member of Crypton2 takes immense pride in being part of this milestone initiative. We strongly believe that through the continuous adoption of innovative technologies and collaborative efforts, our department will one day reach extraordinary heights and set an inspiring example for others to follow.',
                    style: storyBodyStyle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. Development Team & Key Roles (Highlights Grid)
          Text(
            'DEVELOPMENT ARCHITECTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildRoleCard(
            name: 'Saifur Rahman',
            role: 'SYSTEM ARCHITECTURE & BACKEND',
            desc: 'Database Design, Backend Pipelines, and Application Core Implementation.',
            icon: Icons.terminal,
            color: const Color(0xFF00ADB5),
            colors: colors,
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            name: 'Imran Hasan',
            role: 'UI/UX DESIGN & INTERACTION',
            desc: 'Visual Identity, Motion Prefs, Aesthetics, and Frontend User Experience.',
            icon: Icons.palette_outlined,
            color: const Color(0xFFE53935),
            colors: colors,
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            name: 'Alamgir Kabir • Tanvirul Islam',
            role: 'CONCEPT & PLANNING LEADERSHIP',
            desc: 'Initial Concept Planning, Feature Mapping, and Architecture Supervision.',
            icon: Icons.security,
            color: const Color(0xFFFFB300),
            colors: colors,
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            name: 'Tanvirul Islam • Imran Hasan • Alamgir Kabir • Abdul Awal Asif',
            role: 'STRATEGIC PLANNING SUPPORT',
            desc: 'Feature Requirements gathering, Strategy Refinement, and Alpha Release Testing.',
            icon: Icons.hub_outlined,
            color: const Color(0xFF43A047),
            colors: colors,
          ),
          
          const SizedBox(height: 28),

          // 5. Special Thanks Tribute Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0C0B12).withOpacity(isNight ? 0.9 : 0.05),
                  colors.surfaceContainer.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF8E24AA).withOpacity(0.35),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E24AA).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                // Glowing Circular Badge for Crypton 2
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [Colors.purple, Colors.blue, Colors.teal, Colors.purple],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.ac_unit, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SPECIAL THANKS TO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CRYPTON 2',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isNight ? Colors.white : Colors.black87,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.purple.withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    required String year,
    required String title,
    required String description,
    required ColorScheme colors,
    required IconData icon,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Vertical Timeline Node
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(icon, color: colors.primary, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: colors.primary.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Right side: Narrative Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _buildGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: colors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              year,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: colors.onSurface.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String name,
    required String role,
    required String desc,
    required IconData icon,
    required Color color,
    required ColorScheme colors,
  }) {
    return _buildGlassCard(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.onSurface.withOpacity(0.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({Key? key, required Widget child}) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: key,
      elevation: 0,
      color: colors.surfaceContainer.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}
