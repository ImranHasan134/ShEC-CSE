import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../backend/services/accounting_service.dart';
import '../../../../../core/utils/validation_rules.dart';
import '../../bloc/accounting_bloc.dart';
import '../../bloc/accounting_event.dart';
import 'dialog_helpers.dart';

class EditPaymentDialog extends StatefulWidget {
  final FeePayment payment;

  const EditPaymentDialog({
    super.key,
    required this.payment,
  });

  @override
  State<EditPaymentDialog> createState() => _EditPaymentDialogState();
}

class _EditPaymentDialogState extends State<EditPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _remarksController = TextEditingController();

  late String _selectedMonthName;
  late String _selectedYear;
  String _paymentType = 'monthly';

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.payment.amount.toStringAsFixed(0);
    _paymentType = widget.payment.paymentType;
    _eventNameController.text = widget.payment.eventName ?? '';
    _remarksController.text = widget.payment.remarks ?? '';

    _selectedMonthName = monthsList[DateTime.now().month - 1];
    _selectedYear = DateTime.now().year.toString();

    if (widget.payment.month.contains('-')) {
      final parts = widget.payment.month.split('-');
      if (parts.length == 2) {
        _selectedYear = parts[0];
        final monthInt = int.tryParse(parts[1]);
        if (monthInt != null && monthInt >= 1 && monthInt <= 12) {
          _selectedMonthName = monthsList[monthInt - 1];
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _eventNameController.dispose();
    _remarksController.dispose();
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
        child: Form(
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
                        'Edit Fee Payment',
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
                
                // Read-only Member Information
                Text(
                  'Club Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.person, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.payment.memberName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (widget.payment.memberIdRoll != null)
                              Text(
                                widget.payment.memberIdRoll!,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Amount and Payment Type
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
                                child: Text('Monthly Fee', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'event',
                                child: Text('Event Fee', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'admission',
                                child: Text('Admission Fee', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'others',
                                child: Text('Others', overflow: TextOverflow.ellipsis),
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

                // Month & Year Dropdowns
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
                                      child: Text(m, overflow: TextOverflow.ellipsis),
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
                                      child: Text(y, overflow: TextOverflow.ellipsis),
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

                // Conditional Event Name
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

                // Remarks
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
                        if (_formKey.currentState!.validate()) {
                          final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                          context.read<AccountingBloc>().add(
                                UpdateFeePaymentSubmitted(
                                  paymentId: widget.payment.id,
                                  amount: amount,
                                  month: _getTargetMonthString(),
                                  paymentType: _paymentType,
                                  eventName: _paymentType == 'event' ? _eventNameController.text.trim() : null,
                                  remarks: _remarksController.text.trim().isNotEmpty
                                      ? _remarksController.text.trim()
                                      : null,
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
                      child: const Text('Save Changes'),
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
