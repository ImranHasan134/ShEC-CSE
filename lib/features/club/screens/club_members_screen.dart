import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../backend/services/auth_service.dart';
import '../../profile/models/profile_state.dart';

class ClubMembersScreen extends StatefulWidget {
  const ClubMembersScreen({super.key});

  @override
  State<ClubMembersScreen> createState() => _ClubMembersScreenState();
}

class _ClubMembersScreenState extends State<ClubMembersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProfileData> _allMembers = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _copiedValue;

  Future<void> _confirmAndMakeCall(ProfileData member) async {
    final colors = Theme.of(context).colorScheme;
    final phone = member.phone;
    if (phone.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_forwarded, color: Colors.teal),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Phone Call', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Would you like to call ${member.name}?\n\nPhone: $phone',
          style: TextStyle(color: colors.onSurface, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Call'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HapticFeedback.lightImpact();
      final Uri launchUri = Uri(scheme: 'tel', path: phone);
      try {
        bool launched = await launchUrl(launchUri, mode: LaunchMode.externalApplication);
        if (!launched) {
          throw 'App launch returned false';
        }
      } catch (e) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: colors.surface,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline, color: colors.error),
                ),
                const SizedBox(width: 12),
                const Text('Could Not Open Dialer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Text(
              'No phone dialer app could be opened automatically on this device. This is common on simulators or devices without mobile network hardware.\n\nPhone Number: $phone',
              style: TextStyle(color: colors.onSurface, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Dismiss', style: TextStyle(color: colors.onSurfaceVariant)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phone));
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Phone number copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                child: const Text('Copy Number'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _confirmAndSendEmail(ProfileData member) async {
    final colors = Theme.of(context).colorScheme;
    final email = member.email;
    if (email.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mail_outline, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Would you like to send an email to ${member.name}?\n\nEmail: $email',
          style: TextStyle(color: colors.onSurface, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Email'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HapticFeedback.lightImpact();
      final Uri launchUri = Uri(scheme: 'mailto', path: email);
      try {
        bool launched = await launchUrl(launchUri, mode: LaunchMode.externalApplication);
        if (!launched) {
          throw 'App launch returned false';
        }
      } catch (e) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: colors.surface,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline, color: colors.error),
                ),
                const SizedBox(width: 12),
                const Text('Could Not Open Mail App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Text(
              'No default email application could be opened on this device. This is common if no email accounts are set up or if no mail client is installed.\n\nEmail: $email',
              style: TextStyle(color: colors.onSurface, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Dismiss', style: TextStyle(color: colors.onSurfaceVariant)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: email));
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Email address copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                child: const Text('Copy Email'),
              ),
            ],
          ),
        );
      }
    }
  }

  bool get isAdmin => currentProfile.value.role != UserRole.student;

  @override
  void initState() {
    super.initState();
    int tabCount = currentProfile.value.role != UserRole.student ? 3 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await AuthService.fetchAllMembers();
      if (mounted) setState(() => _allMembers = members);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMemberDetails(ProfileData member) {
    final colors = Theme.of(context).colorScheme;
    final currentP = currentProfile.value;
    final isSuperuser = currentP.designation == 'President' || currentP.designation == 'Vice President';
    final isCommittee = currentP.role == UserRole.committeeMember;
    final canManage = isSuperuser || isCommittee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                CircleAvatar(
                  radius: 54,
                  backgroundColor: colors.primary.withOpacity(0.1),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: member.imagePath != null && member.imagePath!.isNotEmpty 
                        ? NetworkImage(member.imagePath!) 
                        : null,
                    child: member.imagePath == null || member.imagePath!.isEmpty
                        ? Text(member.name[0].toUpperCase(), style: const TextStyle(fontSize: 40))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(member.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    member.designation, 
                    style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildModernInfoRow(Icons.badge_outlined, 'Student ID', member.studentFullId),
                _buildModernInfoRow(Icons.school_outlined, 'Session', member.session),
                _buildModernInfoRow(Icons.numbers_outlined, 'DU Reg', member.duRegNo),
                const SizedBox(height: 8),
                _buildElevatedContactCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: member.phone,
                  accentColor: Colors.teal,
                  onActionTap: member.phone.isNotEmpty ? () => _confirmAndMakeCall(member) : null,
                ),
                _buildElevatedContactCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: member.email,
                  accentColor: Colors.blue,
                  onActionTap: member.email.isNotEmpty ? () => _confirmAndSendEmail(member) : null,
                ),
                
                if (canManage && member.id != currentProfile.value.id) ...[
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: Divider(color: colors.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('ADMIN ACTIONS', style: TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.w800, 
                          color: colors.onSurfaceVariant,
                          letterSpacing: 1.5,
                        )),
                      ),
                      Expanded(child: Divider(color: colors.outlineVariant)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (!member.isApproved)
                        _actionButton(
                          colors, 
                          Icons.check_circle_outline, 
                          'Approve User', 
                          Colors.green,
                          () async {
                            Navigator.pop(context);
                            await AuthService.approveUser(member.id);
                            _fetchMembers();
                          }
                        ),
                      
                      _actionButton(
                        colors, 
                        Icons.edit_outlined, 
                        'Update Info', 
                        colors.primary,
                        () {
                          Navigator.pop(context);
                          _showEditMemberSheet(member);
                        }
                      ),

                      if (isSuperuser) ...[
                        _actionButton(
                          colors, 
                          Icons.star_outline, 
                          'Change Rank', 
                          Colors.orange,
                          () => _showDesignationPicker(member)
                        ),
                        _actionButton(
                          colors, 
                          Icons.history_edu_outlined, 
                          'Move To Alumni',
                          Colors.blueGrey,
                          () async {
                            final confirm = await _showConfirmDialog(
                              'Move to Alumni',
                              'Move ${member.name} to the Alumni list?'
                            );
                            if (confirm == true) {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              try {
                                await AuthService.moveToAlumni(member);
                                _fetchMembers();
                              } catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            }
                          }
                        ),
                      ],
                      
                      if (isSuperuser && (member.role == UserRole.committeeMember || member.role == UserRole.superUser))
                        _actionButton(
                          colors, 
                          Icons.person_remove_outlined, 
                          'Demote', 
                          Colors.deepOrange,
                          () => _changeRole(member, UserRole.student, designation: 'Member')
                        ),
                        
                      if (isSuperuser)
                        _actionButton(
                          colors, 
                          Icons.delete_outline, 
                          'Delete', 
                          Colors.red,
                          () {
                            Navigator.pop(context);
                            _deleteMember(member);
                          }
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton(ColorScheme colors, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value, {
    bool isCopyable = false,
    VoidCallback? onActionTap,
    IconData? actionIcon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isCopied = _copiedValue == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.primary.withOpacity(0.7)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value.isNotEmpty ? value : 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (onActionTap != null && value.isNotEmpty) ...[
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    actionIcon ?? Icons.open_in_new, 
                    size: 18, 
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (isCopyable && value.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  setState(() => _copiedValue = value);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _copiedValue = null);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied!'), 
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      width: 150,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCopied ? Colors.green.withOpacity(0.1) : colors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCopied ? Icons.check : Icons.copy_rounded, 
                    size: 18, 
                    color: isCopied ? Colors.green : colors.primary
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedContactCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
    required VoidCallback? onActionTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCopied = _copiedValue == value;

    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : accentColor.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Material(
          color: isDark ? colors.surfaceContainerLow : Colors.white,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark 
                      ? accentColor.withOpacity(0.2) 
                      : accentColor.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 26, color: accentColor),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: isDark ? colors.onSurfaceVariant.withOpacity(0.8) : colors.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: accentColor.withOpacity(0.15), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label == 'Phone' ? 'Call' : 'Mail',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          label == 'Phone' ? Icons.phone_forwarded : Icons.alternate_email,
                          size: 14,
                          color: accentColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      setState(() => _copiedValue = value);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _copiedValue = null);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 1),
                          width: 220,
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCopied ? Colors.green.withOpacity(0.1) : colors.onSurface.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCopied ? Icons.check : Icons.copy_rounded,
                        size: 16,
                        color: isCopied ? Colors.green : colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );
  }

  // --- REST OF THE CODE REMAINS THE SAME ---
  // (Assuming _showEditMemberSheet, _deleteMember, _showDesignationPicker, _changeRole, _fetchMembers, _buildList exist)
  
  void _changeRole(ProfileData member, UserRole newRole, {String? designation}) async {
    try {
      await AuthService.updateUserRole(member.id, newRole, designation: designation);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated successfully')));
        _fetchMembers();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _deleteMember(ProfileData member) async {
    final confirm = await _showConfirmDialog('Delete Member', 'Are you sure you want to delete ${member.name}?');
    if (confirm == true) {
      try {
        await AuthService.deleteUser(member.id);
        _fetchMembers();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showDesignationPicker(ProfileData member) {
    final List<String> standardDesignations = [
      'President', 'Vice President', 'General Secretary', 'Joint Secretary', 
      'Treasurer', 'Press Secretary', 'Executive Member', 'Member'
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: standardDesignations.map((d) => ListTile(
          title: Text(d),
          onTap: () {
            Navigator.pop(context);
            _changeRole(member, d == 'Member' ? UserRole.student : UserRole.committeeMember, designation: d);
          },
        )).toList(),
      ),
    );
  }

  void _showEditMemberSheet(ProfileData member) {
    final colors = Theme.of(context).colorScheme;
    final firstNameController = TextEditingController(text: member.firstName);
    final lastNameController = TextEditingController(text: member.lastName);
    final universityIdController = TextEditingController(text: member.universityId);
    final classRollController = TextEditingController(text: member.classRoll);
    final duRegController = TextEditingController(text: member.duRegNo);
    final phoneController = TextEditingController(text: member.phone);
    String? selectedSession = member.session;
    String? selectedBatch = member.batch;

    final List<String> sessions = List.generate(10, (i) => '${2018 + i}-${2019 + i}');
    final List<String> batches = List.generate(15, (i) => '${10 + i}');

    // Ensure current values are in the lists to prevent crash
    if (selectedSession != null && !sessions.contains(selectedSession)) {
      sessions.add(selectedSession!);
      sessions.sort((a, b) => b.compareTo(a));
    }
    if (selectedBatch != null && !batches.contains(selectedBatch)) {
      batches.add(selectedBatch!);
      batches.sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 12,
          ),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text('Update Member Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(child: TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: universityIdController, decoration: const InputDecoration(labelText: 'University ID', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: classRollController, decoration: const InputDecoration(labelText: 'Class Roll', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: duRegController, decoration: const InputDecoration(labelText: 'DU Reg No', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSession,
                        decoration: const InputDecoration(labelText: 'Session', border: OutlineInputBorder()),
                        items: sessions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setSheetState(() => selectedSession = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedBatch,
                        decoration: const InputDecoration(labelText: 'Batch', border: OutlineInputBorder()),
                        items: batches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (val) => setSheetState(() => selectedBatch = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      try {
                        final updatedMember = member.copyWith(
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          name: '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
                          universityId: universityIdController.text.trim(),
                          classRoll: classRollController.text.trim(),
                          duRegNo: duRegController.text.trim(),
                          phone: phoneController.text.trim(),
                          session: selectedSession,
                          batch: selectedBatch,
                        );
                        
                        await AuthService.updateAnyProfile(updatedMember);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Info updated successfully')));
                          _fetchMembers();
                        }
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    final tabLabelColor = colors.primary;
    final tabUnselectedColor = colors.onSurface.withOpacity(0.6);
    final tabIndicatorColor = colors.primary;

    final filteredAll = _allMembers.where((m) => 
      m.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      m.studentFullId.contains(_searchQuery)
    ).toList();

    final members = filteredAll.where((m) => m.role == UserRole.student && m.isApproved).toList();
    final committees = filteredAll.where((m) => (m.role == UserRole.committeeMember || m.role == UserRole.superUser) && m.isApproved).toList();
    final pending = filteredAll.where((m) => !m.isApproved).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search members...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: tabLabelColor,
                unselectedLabelColor: tabUnselectedColor,
                indicatorColor: tabIndicatorColor,
                tabs: [
                  const Tab(text: 'Members'),
                  const Tab(text: 'Committee'),
                  if (isAdmin)
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Pending '),
                          if (pending.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text('${pending.length}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                            )
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(members),
                _buildList(committees),
                if (isAdmin) _buildList(pending, isPendingList: true),
              ],
            ),
    );
  }

  Widget _buildList(List<ProfileData> list, {bool isPendingList = false}) {
    if (list.isEmpty) {
      return const Center(child: Text('No users found in this category.'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final member = list[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: isPendingList ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12)
          ),
          child: ListTile(
            onTap: () => _showMemberDetails(member),
            leading: CircleAvatar(
              backgroundImage: member.imagePath != null && member.imagePath!.isNotEmpty 
                ? NetworkImage(member.imagePath!) 
                : null,
              child: member.imagePath == null || member.imagePath!.isEmpty
                ? Text(member.name[0].toUpperCase())
                : null,
            ),
            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${member.designation} • Batch: ${member.batch} • ${member.session}'),
                if (member.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          member.email, 
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (member.phone.isNotEmpty) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _confirmAndMakeCall(member),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.teal.withOpacity(0.2), width: 1),
                        ),
                        child: const Icon(
                          Icons.phone,
                          size: 18,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (member.email.isNotEmpty) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _confirmAndSendEmail(member),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
