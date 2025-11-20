import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/word.dart';
import '../models/history.dart';
import '../data/database_helper.dart';

// Events
abstract class WordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchWordsEvent extends WordEvent {
  final String query;
  SearchWordsEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadWordDetailsEvent extends WordEvent {
  final int wordId;
  LoadWordDetailsEvent(this.wordId);
  @override
  List<Object?> get props => [wordId];
}

class LoadRandomWordsEvent extends WordEvent {}

class ClearSearchEvent extends WordEvent {}

// States
abstract class WordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WordInitial extends WordState {}

class WordLoading extends WordState {}

class WordSearchResults extends WordState {
  final List<Word> words;
  final String query;
  
  WordSearchResults(this.words, this.query);
  
  @override
  List<Object?> get props => [words, query];
}

class WordDetailsLoaded extends WordState {
  final Word word;
  
  WordDetailsLoaded(this.word);
  
  @override
  List<Object?> get props => [word];
}

class WordError extends WordState {
  final String message;
  
  WordError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class RandomWordsLoaded extends WordState {
  final List<Word> words;
  
  RandomWordsLoaded(this.words);
  
  @override
  List<Object?> get props => [words];
}

// BLoC
class WordBloc extends Bloc<WordEvent, WordState> {
  final DatabaseHelper dbHelper;

  WordBloc(this.dbHelper) : super(WordInitial()) {
    on<SearchWordsEvent>(_onSearchWords);
    on<LoadWordDetailsEvent>(_onLoadWordDetails);
    on<LoadRandomWordsEvent>(_onLoadRandomWords);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchWords(SearchWordsEvent event, Emitter<WordState> emit) async {
    if (event.query.isEmpty) {
      emit(WordInitial());
      return;
    }

    emit(WordLoading());
    try {
      final words = await dbHelper.searchWords(event.query);
      emit(WordSearchResults(words, event.query));
    } catch (e) {
      emit(WordError('Failed to search words: ${e.toString()}'));
    }
  }

  Future<void> _onLoadWordDetails(LoadWordDetailsEvent event, Emitter<WordState> emit) async {
    emit(WordLoading());
    try {
      final word = await dbHelper.getWordById(event.wordId);
      if (word != null) {
        // Add to history
        await dbHelper.addHistory(History(
          wordId: word.id,
          wordText: word.word,
          searchedAt: DateTime.now(),
        ));
        emit(WordDetailsLoaded(word));
      } else {
        emit(WordError('Word not found'));
      }
    } catch (e) {
      emit(WordError('Failed to load word details: ${e.toString()}'));
    }
  }

  Future<void> _onLoadRandomWords(LoadRandomWordsEvent event, Emitter<WordState> emit) async {
    emit(WordLoading());
    try {
      final words = await dbHelper.getRandomWords(5);
      emit(RandomWordsLoaded(words));
    } catch (e) {
      emit(WordError('Failed to load random words: ${e.toString()}'));
    }
  }

  Future<void> _onClearSearch(ClearSearchEvent event, Emitter<WordState> emit) async {
    emit(WordInitial());
  }
}
