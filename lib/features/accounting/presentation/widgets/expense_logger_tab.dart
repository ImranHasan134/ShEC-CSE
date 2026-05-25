import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../backend/services/accounting_service.dart';
import '../bloc/accounting_bloc.dart';
import '../bloc/accounting_state.dart';
import '../../../profile/models/profile_state.dart';
import 'payment_dialogs.dart';

class ExpenseLoggerTab extends StatefulWidget {
  const ExpenseLoggerTab({super.key});

  @override
  State<ExpenseLoggerTab> createState() => _ExpenseLoggerTabState();
}

class _ExpenseLoggerTabState extends State<ExpenseLoggerTab> {
  String _expenseFilter = 'all';

  bool get _isAdmin {
    final designation = currentProfile.value.designation;
    return designation == 'Treasurer' ||
        designation == 'President' ||
        designation == 'Vice President';
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<AccountingBloc>(),
          child: const AddExpenseDialog(),
        );
      },
    );
  }

  Widget _filterChip(String filterVal, String label, ColorScheme colors) {
    final isSelected = _expenseFilter == filterVal;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _expenseFilter = filterVal);
        }
      },
      selectedColor: colors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? colors.primary : colors.onSurface.withValues(alpha: 0.7),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final state = context.watch<AccountingBloc>().state;
    final hasData = state is AccountingDataLoaded;
    final expenses = hasData ? state.summary.recentExpenses : <ClubExpense>[];

    final filtered = expenses.where((e) {
      if (_expenseFilter == 'all') return true;
      return e.category == _expenseFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text('Filter by:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('all', 'All Expenses', colors),
                        const SizedBox(width: 8),
                        _filterChip('monthly', 'Monthly', colors),
                        const SizedBox(width: 8),
                        _filterChip('event', 'Events', colors),
                        const SizedBox(width: 8),
                        _filterChip('yearly', 'Yearly', colors),
                        const SizedBox(width: 8),
                        _filterChip('others', 'Others', colors),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: colors.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        const Text('No matching expenses logged.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final exp = filtered[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        color: colors.surfaceContainerLowest,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  exp.description,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('- ৳ ${exp.amount.toStringAsFixed(0)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.error, fontSize: 14)),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      exp.category.toUpperCase(),
                                      style: TextStyle(fontSize: 9, color: colors.error, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (exp.eventName != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colors.onSurface.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        exp.eventName!,
                                        style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Text(
                                    DateFormat('d MMM yyyy, h:mm a').format(exp.expenseDate),
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Logged by: ${exp.recordedByName}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  if (exp.remarks != null && exp.remarks!.isNotEmpty)
                                    Text('Note: ${exp.remarks}', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddExpenseDialog(context),
              label: const Text('Log Expense'),
              icon: const Icon(Icons.remove),
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
