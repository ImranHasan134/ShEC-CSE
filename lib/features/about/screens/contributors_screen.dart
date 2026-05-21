import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../backend/services/contributor_service.dart';
import '../../../backend/services/auth_service.dart';
import '../../../core/services/image_processing_service.dart';
import '../../profile/models/profile_state.dart';
import '../models/contributor_item.dart';

class ContributorsScreen extends StatefulWidget {
  const ContributorsScreen({super.key});

  @override
  State<ContributorsScreen> createState() => _ContributorsScreenState();
}

class _ContributorsScreenState extends State<ContributorsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await ContributorService.fetchContributors();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await ContributorService.fetchContributors(forceRefresh: true);
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
      builder: (context) => _AddEditContributorSheet(contributor: contributor),
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

    if (confirm == true) {
      try {
        await ContributorService.deleteContributor(contributor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contributor deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting contributor: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
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
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ValueListenableBuilder<List<ContributorItem>>(
          valueListenable: contributorsState,
          builder: (context, contributors, _) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
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
}

class _AddEditContributorSheet extends StatefulWidget {
  final ContributorItem? contributor;

  const _AddEditContributorSheet({super.key, this.contributor});

  @override
  State<_AddEditContributorSheet> createState() => _AddEditContributorSheetState();
}

class _AddEditContributorSheetState extends State<_AddEditContributorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _contributionController;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;

  File? _imageFile;
  String _imageUrl = '';
  bool _isSaving = false;

  List<ProfileData> _allMembers = [];
  ProfileData? _selectedMember;
  bool _isLoadingMembers = false;

  @override
  void initState() {
    super.initState();
    final c = widget.contributor;
    _nameController = TextEditingController(text: c?.name ?? '');
    _roleController = TextEditingController(text: c?.role ?? '');
    _contributionController = TextEditingController(text: c?.contribution ?? '');
    _githubController = TextEditingController(text: c?.githubUrl ?? '');
    _linkedinController = TextEditingController(text: c?.linkedinUrl ?? '');
    _imageUrl = c?.imagePath ?? '';

    _fetchClubMembers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _contributionController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _fetchClubMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final members = await AuthService.fetchAllMembers();
      setState(() {
        _allMembers = members;
      });
    } catch (e) {
      debugPrint('Error fetching members: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMembers = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        if (!mounted) return;
        final cropped = await ImageProcessingService.cropImage(
          context,
          File(pickedFile.path),
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        );
        if (cropped != null) {
          final processed = await ImageProcessingService.processAndConvert(cropped);
          if (processed != null) {
            setState(() {
              _imageFile = processed;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      String finalImageUrl = _imageUrl;
      if (_imageFile != null) {
        final uploadedUrl = await ContributorService.uploadImage(_imageFile!);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        } else {
          throw Exception('Image upload failed');
        }
      }

      final item = ContributorItem(
        id: widget.contributor?.id ?? '',
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        contribution: _contributionController.text.trim(),
        githubUrl: _githubController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        imagePath: finalImageUrl,
      );

      if (widget.contributor == null) {
        await ContributorService.addContributor(item);
      } else {
        await ContributorService.updateContributor(item);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.contributor == null
                  ? 'Contributor added successfully!'
                  : 'Contributor updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving contributor: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handlebar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                widget.contributor == null ? 'Add Contributor' : 'Edit Contributor',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Image Picker Avatar
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: colors.primary.withOpacity(0.1),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : (_imageUrl.isNotEmpty && _imageUrl.startsWith('http')
                                ? NetworkImage(_imageUrl) as ImageProvider
                                : null),
                        child: _imageFile == null && (_imageUrl.isEmpty || !_imageUrl.startsWith('http'))
                            ? Icon(Icons.add_a_photo_outlined, size: 36, color: colors.primary)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Link Existing Club Member Dropdown (Only for adding new contributor)
              if (widget.contributor == null) ...[
                if (_isLoadingMembers)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (_allMembers.isNotEmpty) ...[
                  DropdownButtonFormField<ProfileData>(
                    value: _selectedMember,
                    decoration: InputDecoration(
                      labelText: 'Link Existing Club Member (Optional)',
                      prefixIcon: const Icon(Icons.person_search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    items: _allMembers.map((member) {
                      return DropdownMenuItem<ProfileData>(
                        value: member,
                        child: Text(
                          '${member.name} (${member.designation})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (member) {
                      if (member != null) {
                        setState(() {
                          _selectedMember = member;
                          _nameController.text = member.name;
                          _roleController.text = member.designation;
                          _imageUrl = member.imagePath ?? '';
                          _imageFile = null; // clear picked image to show network image
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],

              // Form Fields
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: 'Role (e.g. Lead Developer) *',
                  prefixIcon: const Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Role is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contributionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Contribution Description',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _githubController,
                decoration: InputDecoration(
                  labelText: 'GitHub Profile URL',
                  prefixIcon: const Icon(Icons.code_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkedinController,
                decoration: InputDecoration(
                  labelText: 'LinkedIn Profile URL',
                  prefixIcon: const Icon(Icons.link_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GithubPainter extends CustomPainter {
  final Color color;
  GithubPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.22, 0, 0, h * 0.22, 0, h * 0.5);
    path.cubicTo(0, h * 0.72, w * 0.14, h * 0.91, w * 0.34, h * 0.98);
    path.cubicTo(w * 0.37, h * 0.98, w * 0.38, h * 0.97, w * 0.38, h * 0.95);
    path.lineTo(w * 0.38, h * 0.83);
    path.cubicTo(w * 0.24, h * 0.86, w * 0.21, h * 0.77, w * 0.21, h * 0.77);
    path.cubicTo(w * 0.19, h * 0.71, w * 0.16, h * 0.69, w * 0.16, h * 0.69);
    path.cubicTo(w * 0.11, h * 0.66, w * 0.16, h * 0.66, w * 0.16, h * 0.66);
    path.cubicTo(w * 0.21, h * 0.66, w * 0.24, h * 0.71, w * 0.24, h * 0.71);
    path.cubicTo(w * 0.28, h * 0.78, w * 0.35, h * 0.76, w * 0.38, h * 0.75);
    path.cubicTo(w * 0.39, h * 0.71, w * 0.41, h * 0.68, w * 0.42, h * 0.66);
    path.cubicTo(w * 0.31, h * 0.65, w * 0.19, h * 0.60, w * 0.19, h * 0.41);
    path.cubicTo(w * 0.19, h * 0.35, w * 0.21, h * 0.31, w * 0.24, h * 0.27);
    path.cubicTo(w * 0.23, h * 0.26, w * 0.21, h * 0.20, w * 0.25, h * 0.12);
    path.cubicTo(w * 0.25, h * 0.12, w * 0.29, h * 0.10, w * 0.38, h * 0.17);
    path.cubicTo(w * 0.42, h * 0.16, w * 0.46, h * 0.15, w * 0.50, h * 0.15);
    path.cubicTo(w * 0.54, h * 0.15, w * 0.58, h * 0.16, w * 0.58, h * 0.17);
    path.cubicTo(w * 0.71, h * 0.10, w * 0.75, h * 0.12, w * 0.75, h * 0.12);
    path.cubicTo(w * 0.79, h * 0.20, w * 0.77, h * 0.26, w * 0.76, h * 0.27);
    path.cubicTo(w * 0.79, h * 0.31, w * 0.81, h * 0.35, w * 0.81, h * 0.41);
    path.cubicTo(w * 0.81, h * 0.60, w * 0.69, h * 0.65, w * 0.58, h * 0.66);
    path.cubicTo(w * 0.60, h * 0.68, w * 0.62, h * 0.71, w * 0.62, h * 0.76);
    path.lineTo(w * 0.62, h * 0.95);
    path.cubicTo(w * 0.62, h * 0.97, w * 0.63, h * 0.98, w * 0.66, h * 0.98);
    path.cubicTo(w * 0.86, h * 0.91, w * 1.00, h * 0.72, w * 1.00, h * 0.50);
    path.cubicTo(w * 1.00, h * 0.22, w * 0.78, 0, w * 0.50, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LinkedInPainter extends CustomPainter {
  final Color color;
  LinkedInPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw rounded background square
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.2),
    );
    canvas.drawRRect(rect, paint);

    // Draw the "i" and "n" in white
    final textPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw dot of 'i'
    canvas.drawOval(
      Rect.fromCircle(center: Offset(w * 0.29, h * 0.26), radius: w * 0.06),
      textPaint,
    );
    // Draw body of 'i'
    canvas.drawRect(
      Rect.fromLTWH(w * 0.23, h * 0.38, w * 0.12, h * 0.42),
      textPaint,
    );

    // Draw 'n' body and arch
    final nPath = Path();
    nPath.moveTo(w * 0.44, h * 0.38);
    nPath.lineTo(w * 0.55, h * 0.38);
    nPath.lineTo(w * 0.55, h * 0.45);
    nPath.cubicTo(
      w * 0.60, h * 0.36,
      w * 0.74, h * 0.36,
      w * 0.74, h * 0.52,
    );
    nPath.lineTo(w * 0.74, h * 0.8);
    nPath.lineTo(w * 0.63, h * 0.8);
    nPath.lineTo(w * 0.63, h * 0.55);
    nPath.cubicTo(
      w * 0.63, h * 0.48,
      w * 0.59, h * 0.48,
      w * 0.55, h * 0.52,
    );
    nPath.lineTo(w * 0.55, h * 0.8);
    nPath.lineTo(w * 0.44, h * 0.8);
    nPath.close();

    canvas.drawPath(nPath, textPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HUDCornerPainter extends CustomPainter {
  final Color color;
  HUDCornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    const len = 12.0;
    const offset = 1.0;

    // Top-Left
    canvas.drawLine(const Offset(offset, offset + len), const Offset(offset, offset), paint);
    canvas.drawLine(const Offset(offset, offset), const Offset(offset + len, offset), paint);

    // Top-Right
    canvas.drawLine(Offset(w - offset - len, offset), Offset(w - offset, offset), paint);
    canvas.drawLine(Offset(w - offset, offset), Offset(w - offset, offset + len), paint);

    // Bottom-Left
    canvas.drawLine(Offset(offset, h - offset - len), Offset(offset, h - offset), paint);
    canvas.drawLine(Offset(offset, h - offset), Offset(offset + len, h - offset), paint);

    // Bottom-Right
    canvas.drawLine(Offset(w - offset - len, h - offset), Offset(w - offset, h - offset), paint);
    canvas.drawLine(Offset(w - offset, h - offset - len), Offset(w - offset, h - offset), paint);

    // Small cyber circle in corner
    final dotPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w - 8, 8), 2.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CyberMainframeHeader extends StatefulWidget {
  final List<ContributorItem> contributors;
  final Widget Function(BuildContext, List<ContributorItem>) builder;

  const CyberMainframeHeader({
    super.key,
    required this.contributors,
    required this.builder,
  });

  @override
  State<CyberMainframeHeader> createState() => _CyberMainframeHeaderState();
}

class _CyberMainframeHeaderState extends State<CyberMainframeHeader> with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        widget.builder(context, widget.contributors),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _sweepController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: ScanlinePainter(
                      progress: _sweepController.value,
                      color: colors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ScanlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanlinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final y = h * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          color.withOpacity(0.04),
          color.withOpacity(0.18),
          color.withOpacity(0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 25, w, 50));

    canvas.drawRect(Rect.fromLTWH(0, y - 25, w, 50), paint);

    final linePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, y), Offset(w, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class TechRadarAvatar extends StatefulWidget {
  final String imagePath;
  final String name;
  final Color themeColor;
  final double radius;

  const TechRadarAvatar({
    key,
    required this.imagePath,
    required this.name,
    required this.themeColor,
    this.radius = 36,
  }) : super(key: key);

  @override
  State<TechRadarAvatar> createState() => _TechRadarAvatarState();
}

class _TechRadarAvatarState extends State<TechRadarAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.141592653589793,
              child: CustomPaint(
                size: Size((widget.radius + 6) * 2, (widget.radius + 6) * 2),
                painter: RadarRingPainter(widget.themeColor),
              ),
            );
          },
        ),
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: colors.surface,
          child: CircleAvatar(
            radius: widget.radius - 2,
            backgroundImage: widget.imagePath.isNotEmpty && widget.imagePath.startsWith('http')
                ? NetworkImage(widget.imagePath)
                : null,
            child: (widget.imagePath.isEmpty || !widget.imagePath.startsWith('http'))
                ? Text(
                    widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'C',
                    style: TextStyle(
                      fontSize: widget.radius * 0.7,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class RadarRingPainter extends CustomPainter {
  final Color color;
  RadarRingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final radius = w / 2;

    canvas.drawCircle(Offset(radius, radius), radius - 2, paint);

    final notchPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2),
      0,
      0.6,
    );
    path.addArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2),
      2.09,
      0.6,
    );
    path.addArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2),
      4.18,
      0.6,
    );
    canvas.drawPath(path, notchPaint);

    final finePaint = Paint()
      ..color = color.withOpacity(0.12)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(radius, radius), radius + 2, finePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PulsingStatusLight extends StatefulWidget {
  final Color color;
  const PulsingStatusLight({key, required this.color}) : super(key: key);

  @override
  State<PulsingStatusLight> createState() => _PulsingStatusLightState();
}

class _PulsingStatusLightState extends State<PulsingStatusLight> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 2.0, end: 7.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value / 4,
              ),
            ],
          ),
        );
      },
    );
  }
}
