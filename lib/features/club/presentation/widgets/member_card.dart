import 'package:flutter/material.dart';
import '../../../profile/models/profile_state.dart';

class MemberCard extends StatelessWidget {
  final ProfileData member;
  final bool isPendingList;
  final VoidCallback onTap;
  final VoidCallback onCallTap;
  final VoidCallback onEmailTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.isPendingList,
    required this.onTap,
    required this.onCallTap,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isPendingList ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12)
      ),
      child: ListTile(
        onTap: onTap,
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
                  onTap: onCallTap,
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
                  onTap: onEmailTap,
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
  }
}
