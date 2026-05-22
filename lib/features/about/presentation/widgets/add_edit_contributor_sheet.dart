import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../backend/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../profile/models/profile_state.dart';
import '../../domain/entities/contributor_item.dart';
import '../bloc/contributor_bloc.dart';
import '../bloc/contributor_event.dart';

class AddEditContributorSheet extends StatefulWidget {
  final ContributorItem? contributor;

  const AddEditContributorSheet({super.key, this.contributor});

  @override
  State<AddEditContributorSheet> createState() => _AddEditContributorSheetState();
}

class _AddEditContributorSheetState extends State<AddEditContributorSheet> {
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
        final uploadedUrl = await StorageService.uploadFile(_imageFile!, 'alumni_images');
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
        context.read<ContributorBloc>().add(AddContributorRequested(item));
      } else {
        context.read<ContributorBloc>().add(UpdateContributorRequested(item));
      }

      if (mounted) {
        Navigator.pop(context, true);
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
                          _imageFile = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],

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
