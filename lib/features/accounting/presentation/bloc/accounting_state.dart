import 'package:equatable/equatable.dart';
import '../../../../backend/services/accounting_service.dart';

abstract class AccountingState extends Equatable {
  const AccountingState();

  @override
  List<Object?> get props => [];
}

class AccountingInitial extends AccountingState {}

class AccountingLoading extends AccountingState {}

class AccountingDataLoaded extends AccountingState {
  final AccountingSummary summary;

  const AccountingDataLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class AccountingDuesLoaded extends AccountingState {
  final String month;
  final List<MemberDuesStatus> dues;

  const AccountingDuesLoaded({required this.month, required this.dues});

  @override
  List<Object?> get props => [month, dues];
}

class AccountingActionSuccess extends AccountingState {
  final String message;
  final bool isExpenseAdded; // To distinguish what succeeded if needed
  final bool isPaymentAdded;

  const AccountingActionSuccess(
    this.message, {
    this.isExpenseAdded = false,
    this.isPaymentAdded = false,
  });

  @override
  List<Object?> get props => [message, isExpenseAdded, isPaymentAdded];
}

class AccountingError extends AccountingState {
  final String errorMessage;

  const AccountingError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
