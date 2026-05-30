import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../backend/services/auth_service.dart';
import '../../../../../core/utils/validation_rules.dart';
import '../../../../profile/models/profile_state.dart';
import '../../bloc/accounting_bloc.dart';
import '../../bloc/accounting_event.dart';
import 'dialog_helpers.dart';

class AddPaymentDialog extends StatefulWidget {
  final ProfileData? preselectedMember; // Optional preset (e.g. from Dues page click)
  final String? preselectedMonth;       // Optional preset format 'YYYY-MM'

  const AddPaymentDialog({
    super.key,
    this.preselectedMember,
    this.preselectedMonth,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _remarksController = TextEditingController();
  final _memberSearchController = TextEditingController();
  final _externalSourceController = TextEditingController();

  List<ProfileData> _allMembers = [];
  ProfileData? _selectedMember;
  bool _isLoadingMembers = true;
  bool _isExternalPayment = false;

  late String _selectedMonthName;
  late String _selectedYear;
  String _paymentType = 'monthly';

  @override
  void initState() {
    super.initState();
    _selectedMonthName = monthsList[DateTime.now().month - 1];
    _selectedYear = DateTime.now().year.toString();
    _amountController.text = '50'; // Default standard dues fee amount
    
    if (widget.preselectedMember != null) {
      _selectedMember = widget.preselectedMember;
      _memberSearchController.text = widget.preselectedMember!.name;
    }

    if (widget.preselectedMonth != null && widget.preselectedMonth!.contains('-')) {
      final parts = widget.preselectedMonth!.split('-');
      if (parts.length == 2) {
        _selectedYear = parts[0];
        final monthInt = int.tryParse(parts[1]);
        if (monthInt != null && monthInt >= 1 && monthInt <= 12) {
          _selectedMonthName = monthsList[monthInt - 1];
        }
      }
    }

    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await AuthService.fetchAllMembers();
      setState(() {
        _allMembers = members.where((m) => m.isApproved && !m.isAlumni).toList();
        _isLoadingMembers = false;
      });
    } catch (e) {
      setState(() => _isLoadingMembers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load members: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _eventNameController.dispose();
    _remarksController.dispose();
    _memberSearchController.dispose();
    _externalSourceController.dispose();
    super.dispose();
  }

  String _getTargetMonthString() {
    final monthIndex = monthsList.indexOf(_selectedMonthName) + 1;
    final monthStr = monthIndex < 10 ? '0$monthIndex' : '$monthIndex';
    return '$_selectedYear-$monthStr';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: _isLoadingMembers
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Record Fee Payment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(thickness: 0.5, height: 16),

                      // Member vs Sponsor Payment Segmented Toggle Option
                      if (widget.preselectedMember == null) ...[
                        Center(
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('Member Payment'),
                                icon: Icon(Icons.person),
                              ),
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('Sponsor / External'),
                                icon: Icon(Icons.business),
                              ),
                            ],
                            selected: {_isExternalPayment},
                            onSelectionChanged: (Set<bool> newSelection) {
                              setState(() {
                                _isExternalPayment = newSelection.first;
                              });
                            },
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: colors.primary,
                              selectedForegroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // 1. Conditional Input Form based on Payment Mode Selection
                      if (!_isExternalPayment) ...[
                        Text(
                          'Select Club Member *',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        widget.preselectedMember != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: _selectedMember?.imagePath != null &&
                                              _selectedMember!.imagePath!.startsWith('http')
                                          ? NetworkImage(_selectedMember!.imagePath!) as ImageProvider
                                          : null,
                                      child: (_selectedMember?.imagePath == null ||
                                              !_selectedMember!.imagePath!.startsWith('http'))
                                          ? const Icon(Icons.person, size: 16)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedMember?.name ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          Text(
                                            _selectedMember?.studentFullId ?? '',
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Autocomplete<ProfileData>(
                                displayStringForOption: (ProfileData option) => option.name,
                                fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                                  return TextFormField(
                                    controller: textController,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      hintText: 'Search by name or roll...',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    validator: (v) {
                                      if (!_isExternalPayment && _selectedMember == null) {
                                        return 'Please select a valid member from the list';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<ProfileData>.empty();
                                  }
                                  return _allMembers.where((ProfileData option) {
                                    final term = textEditingValue.text.toLowerCase();
                                    return option.name.toLowerCase().contains(term) ||
                                        option.universityId.toLowerCase().contains(term) ||
                                        option.classRoll.toLowerCase().contains(term);
                                  });
                                },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 8,
                                      borderRadius: BorderRadius.circular(12),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 200),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.76,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: colors.surfaceContainer,
                                          ),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final ProfileData option = options.elementAt(index);
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: option.imagePath != null &&
                                                          option.imagePath!.startsWith('http')
                                                      ? NetworkImage(option.imagePath!) as ImageProvider
                                                      : null,
                                                  child: (option.imagePath == null ||
                                                          !option.imagePath!.startsWith('http'))
                                                      ? const Icon(Icons.person, size: 16)
                                                      : null,
                                                ),
                                                title: Text(
                                                  option.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                subtitle: Text(
                                                  option.studentFullId,
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onSelected: (ProfileData selection) {
                                  setState(() {
                                    _selectedMember = selection;
                                  });
                                },
                              ),
                      ] else ...[
                        Text(
                          'Sponsor / Source Name *',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _externalSourceController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Google DeepMind, Sponsors, DU Alumni...',
                            prefixIcon: const Icon(Icons.business),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (v) {
                            if (_isExternalPayment && (v == null || v.trim().isEmpty)) {
                              return 'Please enter the sponsor or external source name';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // 2. Amount and Payment Type
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount (Taka) *',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixText: '৳ ',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  validator: (v) => ValidationRules.validateRequired(v, 'Amount'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Type *',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _paymentType,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'monthly',
                                      child: Text(
                                        'Monthly Fee',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'event',
                                      child: Text(
                                        'Event Fee',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'admission',
                                      child: Text(
                                        'Admission Fee',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'others',
                                      child: Text(
                                        'Others',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _paymentType = val);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Month & Year (Enabled always, critical for tracking month fees)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Month *',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedMonthName,
                                  items: monthsList
                                      .map((m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(
                                              m,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ))
                                      .toList(),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedMonthName = val);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Year *',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedYear,
                                  items: getYearsList()
                                      .map((y) => DropdownMenuItem(
                                            value: y,
                                            child: Text(
                                              y,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ))
                                      .toList(),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedYear = val);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Conditional Event Name
                      if (_paymentType == 'event') ...[
                        Text(
                          'Event Name *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _eventNameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. CSE Fest 2026',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (v) => _paymentType == 'event'
                              ? ValidationRules.validateRequired(v, 'Event name')
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 5. Remarks
                      Text(
                        'Remarks / Note',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Optional instructions or receipts metadata...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate() && (_isExternalPayment || _selectedMember != null)) {
                                final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                                context.read<AccountingBloc>().add(
                                      AddFeePaymentSubmitted(
                                        memberId: _isExternalPayment ? null : _selectedMember!.id,
                                        amount: amount,
                                        month: _getTargetMonthString(),
                                        paymentType: _paymentType,
                                        eventName: _paymentType == 'event' ? _eventNameController.text.trim() : null,
                                        remarks: _remarksController.text.trim().isNotEmpty
                                            ? _remarksController.text.trim()
                                            : null,
                                        externalSource: _isExternalPayment ? _externalSourceController.text.trim() : null,
                                      ),
                                    );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: colors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save Payment'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
