import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/quotations_mock_datasource.dart';
import '../../domain/entities/quotation.dart';

// EVENTS
abstract class QuotationsEvent extends Equatable {
  const QuotationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadQuotations extends QuotationsEvent {
  const LoadQuotations();
}

class SubmitNewQuotation extends QuotationsEvent {
  final DentalQuotation quotation;
  const SubmitNewQuotation(this.quotation);
  @override
  List<Object?> get props => [quotation];
}

class AcceptQuotation extends QuotationsEvent {
  final String quotationId;
  const AcceptQuotation(this.quotationId);
  @override
  List<Object?> get props => [quotationId];
}

class RejectQuotation extends QuotationsEvent {
  final String quotationId;
  const RejectQuotation(this.quotationId);
  @override
  List<Object?> get props => [quotationId];
}

class FilterQuotationsByStatus extends QuotationsEvent {
  final QuotationStatus? status;
  const FilterQuotationsByStatus(this.status);
  @override
  List<Object?> get props => [status];
}

// STATE
class QuotationsState extends Equatable {
  final List<DentalQuotation> allQuotations;
  final QuotationStatus? selectedFilter;
  final bool isLoading;

  const QuotationsState({
    this.allQuotations = const [],
    this.selectedFilter,
    this.isLoading = false,
  });

  List<DentalQuotation> get filteredQuotations {
    if (selectedFilter == null) return allQuotations;
    return allQuotations.where((q) => q.status == selectedFilter).toList();
  }

  int get actionRequiredCount => allQuotations
      .where((q) => q.status == QuotationStatus.quoteSent)
      .length;

  QuotationsState copyWith({
    List<DentalQuotation>? allQuotations,
    QuotationStatus? selectedFilter,
    bool clearFilter = false,
    bool? isLoading,
  }) {
    return QuotationsState(
      allQuotations: allQuotations ?? this.allQuotations,
      selectedFilter:
          clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [allQuotations, selectedFilter, isLoading];
}

// BLOC
class QuotationsBloc extends Bloc<QuotationsEvent, QuotationsState> {
  QuotationsBloc()
      : super(
          QuotationsState(
            allQuotations:
                QuotationsMockDataSource.instance.getInitialQuotations(),
          ),
        ) {
    on<LoadQuotations>(_onLoadQuotations);
    on<SubmitNewQuotation>(_onSubmitNewQuotation);
    on<AcceptQuotation>(_onAcceptQuotation);
    on<RejectQuotation>(_onRejectQuotation);
    on<FilterQuotationsByStatus>(_onFilterQuotations);
  }

  void _onLoadQuotations(LoadQuotations event, Emitter<QuotationsState> emit) {
    emit(state.copyWith(isLoading: true));
    emit(state.copyWith(
      allQuotations: QuotationsMockDataSource.instance.getInitialQuotations(),
      isLoading: false,
    ));
  }

  void _onSubmitNewQuotation(
      SubmitNewQuotation event, Emitter<QuotationsState> emit) {
    final updated = [event.quotation, ...state.allQuotations];
    emit(state.copyWith(allQuotations: updated));
  }

  void _onAcceptQuotation(
      AcceptQuotation event, Emitter<QuotationsState> emit) {
    final updated = state.allQuotations.map((q) {
      if (q.id == event.quotationId) {
        return q.copyWith(
          status: QuotationStatus.accepted,
          convertedOrderId:
              'ord_rfq_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      return q;
    }).toList();
    emit(state.copyWith(allQuotations: updated));
  }

  void _onRejectQuotation(
      RejectQuotation event, Emitter<QuotationsState> emit) {
    final updated = state.allQuotations.map((q) {
      if (q.id == event.quotationId) {
        return q.copyWith(status: QuotationStatus.rejected);
      }
      return q;
    }).toList();
    emit(state.copyWith(allQuotations: updated));
  }

  void _onFilterQuotations(
      FilterQuotationsByStatus event, Emitter<QuotationsState> emit) {
    emit(state.copyWith(
      selectedFilter: event.status,
      clearFilter: event.status == null,
    ));
  }
}
