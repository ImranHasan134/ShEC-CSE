import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/models/profile_state.dart';
import '../../models/teacher_state.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../screens/teacher_detail_screen.dart';

class TeacherCard extends StatelessWidget {
  final TeacherContact teacher;
  final ProfileData profile;
  final VoidCallback onEdit;

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isAdmin = profile.role != UserRole.student;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TeacherDetailScreen(teacher: teacher)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colors.primaryContainer,
                backgroundImage: teacher.imagePath.isNotEmpty ? NetworkImage(teacher.imagePath) : null,
                child: teacher.imagePath.isEmpty
                    ? Text(
                        teacher.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 26,
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
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
                            teacher.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (!teacher.isApproved)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PENDING',
                              style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      teacher.designation,
                      style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    if (teacher.areasOfExpertise.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: teacher.areasOfExpertise
                            .take(3)
                            .map((area) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    area,
                                    style: TextStyle(color: colors.onPrimaryContainer, fontSize: 10),
                                  ),
                                ))
                            .toList(),
                      ),
                    if (isAdmin) ...[
                      const Divider(height: 16, thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Admin Actions',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface.withValues(alpha: 0.4),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          _buildTeacherAdminMenu(context, teacher, profile),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherAdminMenu(BuildContext context, TeacherContact teacher, ProfileData profile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!teacher.isApproved &&
            (profile.designation == 'President' || profile.designation == 'Vice President')) ...[
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Approve Teacher',
            onPressed: () {
              context.read<TeacherBloc>().add(ApproveTeacherRequested(id: teacher.id));
            },
          ),
          const SizedBox(width: 12),
        ],
        IconButton(
          icon: Icon(
            teacher.isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.orange,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: teacher.isVisible ? 'Hide Teacher' : 'Show Teacher',
          onPressed: () {
            context.read<TeacherBloc>().add(ToggleTeacherVisibilityRequested(
                  id: teacher.id,
                  isVisible: !teacher.isVisible,
                ));
          },
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Edit Teacher',
          onPressed: onEdit,
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Delete Teacher',
          onPressed: () {
            context.read<TeacherBloc>().add(DeleteTeacherRequested(teacher: teacher));
          },
        ),
      ],
    );
  }
}
