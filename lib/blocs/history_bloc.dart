import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/history.dart';
import '../data/database_helper.dart';

// Events
abstract class HistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends HistoryEvent {}

class ClearHistoryEvent extends HistoryEvent {}

// States
abstract class HistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<History> history;
  
  HistoryLoaded(this.history);
  
  @override
  List<Object?> get props => [history];
}

class HistoryCleared extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;
  
  HistoryError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final DatabaseHelper dbHelper;

  HistoryBloc(this.dbHelper) : super(HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  Future<void> _onLoadHistory(LoadHistoryEvent event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final history = await dbHelper.getHistory(limit: 100);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError('Failed to load history: ${e.toString()}'));
    }
  }

  Future<void> _onClearHistory(ClearHistoryEvent event, Emitter<HistoryState> emit) async {
    try {
      await dbHelper.clearHistory();
      emit(HistoryCleared());
      add(LoadHistoryEvent());
    } catch (e) {
      emit(HistoryError('Failed to clear history: ${e.toString()}'));
    }
  }
}
