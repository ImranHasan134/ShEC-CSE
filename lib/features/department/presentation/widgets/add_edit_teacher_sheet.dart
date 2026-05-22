import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../backend/services/teacher_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../profile/models/profile_state.dart';
import '../../models/teacher_state.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';

class AddEditTeacherSheet extends StatefulWidget {
  final TeacherContact? existingTeacher;

  const AddEditTeacherSheet({super.key, this.existingTeacher});

  @override
  State<AddEditTeacherSheet> createState() => _AddEditTeacherSheetState();
}

class _AddEditTeacherSheetState extends State<AddEditTeacherSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _designationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _officeController;
  late final TextEditingController _departmentController;
  late final TextEditingController _joinYearController;
  late final TextEditingController _expertiseController;

  late List<String> _expertiseList;
  late bool _isVisible;
  bool _isUploading = false;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final teacher = widget.existingTeacher;
    _nameController = TextEditingController(text: teacher?.name ?? '');
    _designationController = TextEditingController(text: teacher?.designation ?? '');
    _phoneController = TextEditingController(text: teacher?.phone ?? '');
    _emailController = TextEditingController(text: teacher?.email ?? '');
    _officeController = TextEditingController(text: teacher?.officeRoom ?? '');
    _departmentController = TextEditingController(text: teacher?.department ?? 'CSE');
    _joinYearController = TextEditingController(text: teacher?.joinYear ?? '');
    _expertiseController = TextEditingController();

    _expertiseList = List.from(teacher?.areasOfExpertise ?? []);
    _isVisible = teacher?.isVisible ?? true;
    _currentImageUrl = teacher?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _officeController.dispose();
    _departmentController.dispose();
    _joinYearController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (!mounted) return;

      // 1. Crop Image (Square for teachers)
      final cropped = await ImageProcessingService.cropImage(
        context,
        File(picked.path),
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (cropped != null) {
        // 2. Compress and Convert to WebP
        final processed = await ImageProcessingService.processAndConvert(cropped);
        if (processed != null) {
          setState(() => _selectedImage = processed);
        }
      }
    }
  }

  Widget _field(TextEditingController ctrl, String label, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingTeacher == null ? 'Add Teacher' : 'Edit Teacher',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                          ? NetworkImage(_currentImageUrl!) as ImageProvider
                          : null),
                  child: (_selectedImage == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                      ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _field(_nameController, 'Full Name *'),
            const SizedBox(height: 12),
            _field(_designationController, 'Designation (e.g. Assistant Professor) *'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field(_departmentController, 'Department')),
              const SizedBox(width: 12),
              Expanded(child: _field(_joinYearController, 'Join Year')),
            ]),
            const SizedBox(height: 12),
            _field(_officeController, 'Office Room'),
            const SizedBox(height: 12),
            _field(_phoneController, 'Phone', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _field(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const Text('Areas of Expertise', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: _expertiseList
                  .map((e) => Chip(
                        label: Text(e, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _expertiseList.remove(e)),
                      ))
                  .toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expertiseController,
                    decoration: const InputDecoration(
                      hintText: 'Add area (e.g. Machine Learning)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    if (_expertiseController.text.isNotEmpty) {
                      setState(() {
                        _expertiseList.add(_expertiseController.text.trim());
                        _expertiseController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Visible to Members'),
              value: _isVisible,
              onChanged: (val) => setState(() => _isVisible = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading
                    ? null
                    : () async {
                        if (_nameController.text.isEmpty || _designationController.text.isEmpty) return;
                        setState(() => _isUploading = true);
                        String? finalImageUrl = _currentImageUrl;
                        if (_selectedImage != null) {
                          finalImageUrl = await TeacherService.uploadImage(_selectedImage!);
                        }
                        final teacher = TeacherContact(
                          id: widget.existingTeacher?.id ?? '',
                          name: _nameController.text.trim(),
                          designation: _designationController.text.trim(),
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim(),
                          officeRoom: _officeController.text.trim(),
                          department: _departmentController.text.trim(),
                          joinYear: _joinYearController.text.trim(),
                          areasOfExpertise: _expertiseList,
                          imagePath: finalImageUrl ?? '',
                          isVisible: _isVisible,
                          createdByName: widget.existingTeacher?.createdByName ?? currentProfile.value.name,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          if (widget.existingTeacher == null) {
                            context.read<TeacherBloc>().add(AddTeacherRequested(teacher: teacher));
                          } else {
                            context.read<TeacherBloc>().add(UpdateTeacherRequested(teacher: teacher));
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(widget.existingTeacher == null ? 'Save Teacher' : 'Update'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
