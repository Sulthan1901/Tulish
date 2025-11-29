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
    print('🔍 SearchWordsEvent triggered: "${event.query}"');
    
    if (event.query.isEmpty) {
      print('⚠️ Query is empty, emitting WordInitial');
      emit(WordInitial());
      return;
    }

    emit(WordLoading());
    print('⏳ Loading...');
    
    try {
      print('🔎 Searching database for: "${event.query}"');
      final words = await dbHelper.searchWords(event.query);
      print('✅ Search complete! Found ${words.length} results');
      
      if (words.isEmpty) {
        print('⚠️ No words found for query: "${event.query}"');
      } else {
        print('📚 Results:');
        for (var word in words) {
          print('   - ${word.word}');
        }
      }
      
      emit(WordSearchResults(words, event.query));
    } catch (e) {
      print('❌ Search error: $e');
      print('Stack trace: ${StackTrace.current}');
      emit(WordError('Failed to search words: ${e.toString()}'));
    }
  }

  Future<void> _onLoadWordDetails(LoadWordDetailsEvent event, Emitter<WordState> emit) async {
    print('📖 LoadWordDetailsEvent triggered for ID: ${event.wordId}');
    emit(WordLoading());
    
    try {
      final word = await dbHelper.getWordById(event.wordId);
      
      if (word != null) {
        print('✅ Word found: ${word.word}');
        
        // Add to history
        await dbHelper.addHistory(History(
          wordId: word.id,
          wordText: word.word,
          searchedAt: DateTime.now(),
        ));
        print('📝 Added to history');
        
        emit(WordDetailsLoaded(word));
      } else {
        print('❌ Word not found for ID: ${event.wordId}');
        emit(WordError('Word not found'));
      }
    } catch (e) {
      print('❌ Error loading word details: $e');
      emit(WordError('Failed to load word details: ${e.toString()}'));
    }
  }

  Future<void> _onLoadRandomWords(LoadRandomWordsEvent event, Emitter<WordState> emit) async {
    print('🎲 LoadRandomWordsEvent triggered');
    emit(WordLoading());
    
    try {
      // First, check total words in database
      final totalCount = await dbHelper.getTotalWordCount();
      print('📊 Total words in database: $totalCount');
      
      if (totalCount == 0) {
        print('⚠️ Database is empty! No words to load');
        emit(RandomWordsLoaded([]));
        return;
      }
      
      final words = await dbHelper.getRandomWords(5);
      print('🎲 Loaded ${words.length} random words');
      
      if (words.isNotEmpty) {
        print('📚 Random words:');
        for (var word in words) {
          print('   - ${word.word}');
        }
      }
      
      emit(RandomWordsLoaded(words));
    } catch (e) {
      print('❌ Error loading random words: $e');
      print('Stack trace: ${StackTrace.current}');
      emit(WordError('Failed to load random words: ${e.toString()}'));
    }
  }

  Future<void> _onClearSearch(ClearSearchEvent event, Emitter<WordState> emit) async {
    print('🗑️ ClearSearchEvent triggered');
    emit(WordInitial());
  }
}