import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../backend/services/accounting_service.dart';
import '../../../../../core/utils/validation_rules.dart';
import '../../bloc/accounting_bloc.dart';
import '../../bloc/accounting_event.dart';

class EditExpenseDialog extends StatefulWidget {
  final ClubExpense expense;

  const EditExpenseDialog({
    super.key,
    required this.expense,
  });

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _remarksController = TextEditingController();

  String _category = 'monthly';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.expense.amount.toStringAsFixed(0);
    _descriptionController.text = widget.expense.description;
    _category = widget.expense.category;
    _eventNameController.text = widget.expense.eventName ?? '';
    _remarksController.text = widget.expense.remarks ?? '';
    _selectedDate = widget.expense.expenseDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _eventNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
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
                        'Edit Club Expense',
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

                // Recorded By
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 16, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Recorded By: ',
                        style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        widget.expense.recordedByName,
                        style: TextStyle(fontSize: 11, color: colors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Amount
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
                const SizedBox(height: 16),

                // Category & Date
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category *',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _category,
                            items: const [
                              DropdownMenuItem(
                                value: 'monthly',
                                child: Text('Monthly Expenses', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'event',
                                child: Text('Event Expenses', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: 'yearly',
                                child: Text('Yearly Expenses', overflow: TextOverflow.ellipsis),
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
                                setState(() => _category = val);
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
                            'Expense Date *',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat('d MMM, yyyy').format(_selectedDate),
                                      style: TextStyle(fontSize: 14, color: colors.onSurface),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today, size: 18, color: colors.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Conditional Event Name
                if (_category == 'event') ...[
                  Text(
                    'Event Name *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _eventNameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. CSE Iftar Party 2026',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => _category == 'event'
                        ? ValidationRules.validateRequired(v, 'Event name')
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Description
                Text(
                  'Description / Purpose *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Describe where the money was spent...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => ValidationRules.validateRequired(v, 'Description'),
                ),
                const SizedBox(height: 16),

                // Remarks
                Text(
                  'Remarks / Note',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  decoration: InputDecoration(
                    hintText: 'Optional notes, receipts info, etc.',
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
                                UpdateExpenseSubmitted(
                                  expenseId: widget.expense.id,
                                  amount: amount,
                                  category: _category,
                                  description: _descriptionController.text.trim(),
                                  expenseDate: _selectedDate,
                                  eventName: _category == 'event' ? _eventNameController.text.trim() : null,
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
